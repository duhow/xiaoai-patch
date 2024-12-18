from __future__ import annotations

import logging
from typing import Any

import homeassistant.helpers.config_validation as cv
import voluptuous as vol
from homeassistant import config_entries
from homeassistant.const import (
  CONF_NAME,
  CONF_HOST,
  CONF_PORT,
  ATTR_SERIAL_NUMBER as CONF_SERIAL,
)
from homeassistant.core import HomeAssistant
from homeassistant.data_entry_flow import FlowResult
from homeassistant.exceptions import HomeAssistantError
from homeassistant.components import zeroconf
from homeassistant.helpers.aiohttp_client import async_get_clientsession

from .const import DOMAIN

_LOGGER = logging.getLogger(__name__)

CONFIG_SCHEMA = vol.Schema(
    {
        vol.Required(CONF_HOST): cv.string,
        vol.Required(CONF_PORT, default=80): int,
    }
)

async def validate_input(hass: HomeAssistant, data: dict) -> dict[str, Any]:
    """Validate the user input allows us to connect.

    Data has the keys from DATA_SCHEMA with values provided by the user.
    """
    session = async_get_clientsession(hass)
    api_url = f"http://{data[CONF_HOST]}:{data[CONF_PORT]}"
    async with session.get(f"{api_url}/config") as response:
        if response.status != 200:
            raise HomeAssistantError("Cannot connect to the device")
        result = await response.json()
        result = result.get("data", {})
        if not result.get("listener", {}).get("HA_AUTH_SETUP"):
            raise HomeAssistantError("Device not configured for Home Assistant")
    async with session.get(f"{api_url}/device/info") as response:
        if response.status != 200:
            raise HomeAssistantError("Cannot get device info")
        device_info = await response.json()
        device_info = device_info.get("data", {})
        if device_info.get("model") not in ["LX06"]:
            raise HomeAssistantError("Device not compatible")

    return {CONF_SERIAL: device_info["serial_number"], CONF_NAME: device_info["hostname"]}

class XiaoaiAssistConfigFlow(config_entries.ConfigFlow, domain=DOMAIN):
    VERSION = 1
    stored_input = dict()
    
    def __init__(self) -> None:
        self.discovery_info = {}
    
    async def async_step_zeroconf(
        self, discovery_info: zeroconf.ZeroconfServiceInfo
    ) -> config_entries.ConfigFlowResult:
        """Handle zeroconf discovery."""
        host = discovery_info.host

        # Avoid probing devices that already have an entry
        self._async_abort_entries_match({CONF_HOST: host})

        port = discovery_info.port
        zctype = discovery_info.type
        name = discovery_info.name.replace(f".{zctype}", "")
        unique_id = None

        self.discovery_info.update(
            {
                CONF_HOST: host,
                CONF_PORT: port,
                CONF_NAME: name,
            }
        )

        if unique_id:
            # If we already have the unique id, try to set it now
            # so we can avoid probing the device if its already
            # configured or ignored
            await self._async_set_unique_id_and_abort_if_already_configured(unique_id)
        
        return await self.complete_setup()
    
    async def async_step_zeroconf_confirm(
        self, user_input: dict[str, Any] | None = None
    ) -> config_entries.ConfigFlowResult:
        """Handle a confirmation flow initiated by zeroconf."""
        if user_input is None:
            return self.async_show_form(
                step_id="zeroconf_confirm",
                description_placeholders={"name": self.discovery_info[CONF_NAME]},
                errors={},
            )

        return self.async_create_entry(
            title=self.discovery_info[CONF_NAME],
            data=self.discovery_info,
        )
        
    async def complete_setup(self):
        """ Common action, perform validation of input and create entity if success """
        unique_id = None
        try:
            info = await validate_input(self.hass, self.discovery_info)
            self.discovery_info.update(info)
        except HomeAssistantError:
            return self.async_abort(reason="cannot_connect")

        if not unique_id and info[CONF_SERIAL]:
            unique_id = info[CONF_SERIAL]
        elif not unique_id:
            unique_id = info[CONF_NAME]

        if unique_id and self.unique_id != unique_id:
            await self._async_set_unique_id_and_abort_if_already_configured(unique_id)

        await self._async_handle_discovery_without_unique_id()
        return await self.async_step_zeroconf_confirm()
        
    async def async_step_user(self, user_input: dict[str, Any] | None = None) -> FlowResult:
        if user_input is not None:
            self.discovery_info = user_input
            return await self.complete_setup()

        return self.async_show_form(
            step_id="user", data_schema=CONFIG_SCHEMA
        )
    
    async def _async_set_unique_id_and_abort_if_already_configured(
        self, unique_id: str
    ) -> None:
        """Set the unique ID and abort if already configured."""
        await self.async_set_unique_id(unique_id)
        self._abort_if_unique_id_configured(
            updates={
                CONF_HOST: self.discovery_info[CONF_HOST],
                CONF_NAME: self.discovery_info[CONF_NAME],
            },
        )
