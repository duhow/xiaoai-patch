# List of update files

|Model | Version  | MD5                              | Update type |
|------|----------|----------------------------------|-------------|
| s12a | 1.24.5   | 1146eae7801def461afac944ff1a3691 | all |
| s12a | 1.24.14  | a4b730276b50a5e038e54288f3f6f987 | all |
| s12a | 1.34.39  | ce341f4f379b572320d25d51a40668c3 | firmware |
| s12a | 1.44.4   | 62c355fbae2104aa60519734893f86a5 | all |
| s12a | 1.52.1   | 82af6e8a70164affad18c832a80c731c | all |
| s12a | 1.73.23  | ddc2efab4736422f2829ce2710521fc2 | firmware |
| s12  | 1.52.1   | bf456d334512a978bc03bf19c6f0d292 | firmware |
| s12  | 1.54.1   | cc82bbfa5cd305c7af57f2fa98ff07b1 | firmware |
| s12  | 1.59.28  | 2d2ab3bf0d9b4703a80741a1b6748c1e | firmware |
| lx01 | 1.6.21   | N/A | (CHANNEL=release) |
| lx01 | 1.21.50  | N/A | (CHANNEL=current) |
| lx01 | 1.59.3   | 5d2c40853b21443d8d2152bfe99ec686 | firmware |
| lx05 | 1.50.10  | N/A | firmware |
| lx05 | 1.74.7   | 2bf440d5d3ad371f47c87549e3974be6 | skr_firmware |
| lx05 | 1.79.13  | 6937ee01a0c4aff0c3c91ab1e3d82551 | skr_all |
| l05b | 1.59.22  | 423918ea0e863eff6dce8d8cd44091de | nuttx (from l05c family) |
| l05c | 1.59.27  | ce81a217d82d0e1b997b2f3973d110eb | nuttx |
| lx06 | 1.58.13  | 892f50c64a55d9187736f7ff0288b63c | firmware |
| lx06 | 1.66.7   | a82cce43a0d99895fd8c6959968801e0 | firmware |
| lx06 | 1.66.8   | b78a79a9c4ecb25d462743b7bc1fbfe5 | firmware |
| lx06 | 1.70.2   | fd0f96173b7388b410346b768bd4e7d3 | firmware |
| lx06 | 1.70.4   | 67e2c99e4b2f3a6ebe96671ab9f80b53 | firmware |
| lx06 | 1.74.1   | 66643b82aa60eff9ac99b7688c8b9cbb | all |
| lx06 | 1.74.10  | fe6edc680d58620019c9afe4fd79c712 | firmware |
| lx06 | 1.77.6   | 977ff0c09a95a109a3d049ba9700395b | firmware |
| l07a | 1.76.2   | N/A | skr_firmware |
| l07a | 1.80.4   | a1513a09312e8f493c86602225367517 | skr_firmware |
| l09g | 1.44.21  | b2204ae2c465296e78607669d4300107 | l09g |
| l09g | 1.44.27  | 8b98549f604d4fca1e3f75200ea6c5c9 | l09g |
| l09a | 1.54.0   | 9376a09e3c23e68102b4ad7c449d632e | all |
| l09a | 1.54.10  | N/A | |
| l09a | 1.64.4   | N/A | |
| l09a | 1.64.64  | N/A | |
| l09a | 1.68.1   | N/A | |
| l09a | 1.76.4   | 61c157b288598f279a083b9078024283 | firmware |
| l15a | 1.70.103 | N/A | |
| l15a | 1.81.4   | 612acf5eddf9fdb85d189540e4cb1a32 | all |
| l16a | 1.83.24  | 678b1884700bf4dd88105d1d7806c122 | all |
| x08a | 1.20.11  | 71e0f132f6474da1785926c9b37dbc2f | payload |
| x08a | 2.9.6    | ca7fff56dd301737e35ccdefbf0576a6 | payload |

This is a list of all the updates found for different speakers / devices.
You can download from two hosts:
- `bigota.miwifi.com`
- `cdn.cnbj1.fds.api.mi-img.com`
- `cdn.awsde0-fusion.fds.api.mi-img.com`

Download path is `$HOST/xiaoqiang/rom/$MODEL_NAME/`.

Update file name is `mico_{updateType}_{md5}_{version}.bin`.  
For `l05b/c`, file name is `mico_{md5}_{version}_nuttx.bin.lzma`.  
For `x08a`, file name is `payload_{version}_{md5}.bin`.  

MD5 is the **last 5** characters of the MD5 from same file.
(file is named after being hashed)
