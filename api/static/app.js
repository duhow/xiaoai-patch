function discoverHomeAssistant() {
  return fetch('/discover')
    .then(response => response.json())
    .then(data => {
      const hostname = data.hostname;
      document.querySelector('.brand-logo').textContent = hostname;
      data.instances.forEach(instance => {
        const card = `
          <div class="col s12 m12 l6">
            <div class="card">
              <div class="card-content">
                <span class="card-title">${instance.location_name}</span>
                <p>${instance.base_url} - ${instance.version}</p>
              </div>
              <div class="card-action">
                <form action="/auth" method="post">
                  <input type="hidden" name="url" value="${instance.base_url}">
                  <button type="submit" class="btn">Authenticate</button>
                </form>
              </div>
            </div>
          </div>
        `;
        document.querySelector('.container .row').insertAdjacentHTML('beforeend', card);
      });
    })
    .catch(error => {
      console.error('Error fetching data:', error);
    });
}

function getConfig() {
  return fetch('/config')
    .then(response => response.json())
    .then(data => {
      config = data.data;
      console.log('Config:', config);
      Object.keys(config.listener).forEach(key => {
        const input = document.querySelector(`input[name="${key.toLowerCase()}"]`);
        if (input) {
          input.value = config.listener[key];
        }
      });
      if (config.tts && config.tts.LANGUAGE) {
        document.querySelector('input[name="tts_language"]').value = config.tts.LANGUAGE;
      }
      M.updateTextFields();
    })
    .catch(error => {
      console.error('Error fetching data:', error);
    });
}

function getWakewords() {
  return fetch('/config/wakewords')
    .then(response => response.json())
    .then(data => {
      const select = document.querySelector('select[name="word"]');
      data.data.wakewords.forEach(wakeword => {
        const option = document.createElement('option');
        option.value = wakeword;
        option.textContent = wakeword;
        if (config.listener.WORD === wakeword) {
          option.selected = true;
        }
        select.appendChild(option);
      });
      M.updateTextFields();
      M.FormSelect.init(select);
    })
    .catch(error => {
      console.error('Error fetching wakewords:', error);
    });
}

let config = {};

function initPage() {
  getConfig().then(() => {
    if (!config.listener || !config.listener.HA_AUTH_SETUP) {
      document.querySelector('#discover').style.display = 'block';
      discoverHomeAssistant();
    } else {
      document.querySelector('#config').style.display = 'block';
      getWakewords();
    }
  });
}