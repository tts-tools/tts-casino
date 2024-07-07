import fs from 'fs-extra';
import fetch from 'node-fetch';

import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);

const TTS_PATH = '/home/yeet/Development/projects/lua/TTS-Casino/src/tts';
// const TTS_ASSETS_PATH = '/home/yeet/Downloads/TTS-Casino/chips';
const TTS_ASSETS_PATH = '/home/yeet/Downloads/TTS-Casino/table';

const chips = {
  '$1': 'http://cloud-3.steamusercontent.com/ugc/2508023918742004130/A829F356C4CA8B5A2F93967BFD37A97ED7ECDBD4/',
  '$10': 'http://cloud-3.steamusercontent.com/ugc/2508023918742005237/8FF1CA5E702001F882BFBE7A49C28112F9BB3042/',
  '$100': 'http://cloud-3.steamusercontent.com/ugc/2508023918742035011/B76C5E743E9777B9473A3559C5B632A0E4FAA402/',
  '$1K': 'http://cloud-3.steamusercontent.com/ugc/2508023918742034147/45623683EF4A421F664BCF2B0820E7043E5BF359/',
  '$10K': 'http://cloud-3.steamusercontent.com/ugc/2508023918742033637/4B1549ECC65A7423EBEF05AA07548219E398E909/',
  '$100K': 'http://cloud-3.steamusercontent.com/ugc/2508023918742033240/47925846709ECAAA87D09B26F88103BFFEE8211B/',
  '$1M': 'http://cloud-3.steamusercontent.com/ugc/2508023918742032790/A8CEC262A0E5B3277195525888DC27E8A53F451D/',
  '$10M': 'http://cloud-3.steamusercontent.com/ugc/2508023918742032172/6D6740AD559D417572E7A3871AD90DAFBB6A7B60/',
  '$100M': 'http://cloud-3.steamusercontent.com/ugc/2508023918742031842/C7A5E5FEA20AACA6E77664C01FABA24FEA499E59/',
  '$1B': 'http://cloud-3.steamusercontent.com/ugc/2508023918742030667/539E06AAE1EE49C7C6627A295A6B7F98FFB94CA8/',
  '$10B': 'http://cloud-3.steamusercontent.com/ugc/2508023918742030226/07DD6217783DED1C36C5BD0B8429D93B4035144F/',
  '$100B': 'http://cloud-3.steamusercontent.com/ugc/2508023918742029910/E8B701EB00D4ED5B4A53E681675E7D9BB96EA67D/',
  '$1T': 'http://cloud-3.steamusercontent.com/ugc/2508023918742028806/0DB2CDA8E2393C8CA487142521C948C7D0DB5F4E/',
  '$10T': 'http://cloud-3.steamusercontent.com/ugc/2508023918742028254/BA2C393CE294FBC5CCF8DC9E2719ADC0BA3E8D75/',
  '$100T': 'http://cloud-3.steamusercontent.com/ugc/2508023918742027782/FCBFD21B18BDA6F73D59C8B98F920E347994CE24/',
  '$1q': 'http://cloud-3.steamusercontent.com/ugc/2508023918742025019/B14D7B64D307FD974DFC6D3CB530D0880A7AAE4B/',
  '$10q': 'http://cloud-3.steamusercontent.com/ugc/2508023918742024537/DEF9C72FD2B2AB2945157634C99497E48B92C798/',
  '$100q': 'http://cloud-3.steamusercontent.com/ugc/2508023918742023850/6ABA5F73FFF5EC63F9DE38071E1C4681E39879B6/',
  '$1Q': 'http://cloud-3.steamusercontent.com/ugc/2508023918742023023/772BC346A54BC0A25105701C24C6BAC853A6F0FA/',
  '$10Q': 'http://cloud-3.steamusercontent.com/ugc/2508023918742022525/6CF7DCA0852E6589FE40AE974B35A35D4EDBA942/',
  '$100Q': 'http://cloud-3.steamusercontent.com/ugc/2508023918742021918/2FADBBEC37CF2491A876416BF585A64B5E4DFCEE/',
  '$1s': 'http://cloud-3.steamusercontent.com/ugc/2508023918742020524/436C1BA852A4E8E3D02B9713CE07E16E5A731329/',
  '$10s': 'http://cloud-3.steamusercontent.com/ugc/2508023918742019917/B45BBFC9B25CD5E0F202E13D33E3AA7C3A7E796C/',
  '$100s': 'http://cloud-3.steamusercontent.com/ugc/2508023918742019231/3C76E56F61CBABA9AA035611B0C31D1A11AB4CF7/',
  '$1S': 'http://cloud-3.steamusercontent.com/ugc/2508023918742016844/10439B5D82181E256DE81F38AAB2C1FC97A13658/',
  '$10S': 'http://cloud-3.steamusercontent.com/ugc/2508023918742016427/DCCC7A307412EE65EAD59B21B7B83D62265CDA28/',
  '$100S': 'http://cloud-3.steamusercontent.com/ugc/2508023918742015960/C8820F0EE5D905738F4F8C8E64D10E1E45A708B2/',
  '$1o': 'http://cloud-3.steamusercontent.com/ugc/2508023918742014458/D866DA9803EE70F1365F37DC934D6EC1AC0737DD/',
  '$10o': 'http://cloud-3.steamusercontent.com/ugc/2508023918742014103/8245D1FD19B1D8EBBDFC1EC9DF3284B0F1B633AE/',
  '$100o': 'http://cloud-3.steamusercontent.com/ugc/2508023918742013559/02DC0DA6F236B3CC9E3EF9B10446A29AF12BB9B4/',
  '$1N': 'http://cloud-3.steamusercontent.com/ugc/2508023918742012752/EFD1A379AC765C96A04FCA3E8CDC01B2B627A248/',
  '$10N': 'http://cloud-3.steamusercontent.com/ugc/2508023918742012142/23A72EC4639FE7497A77639D3736CDF2D9387DD9/',
  '$100N': 'http://cloud-3.steamusercontent.com/ugc/2508023918742011590/84FC4871DD9E630F08D4BC7D3D3692DD41957B97/',
  '$1D': 'http://cloud-3.steamusercontent.com/ugc/2508023918742009982/FC23C43F48523859BB20942D3E4ED5B2DCE9DF71/',
  '$10D': 'http://cloud-3.steamusercontent.com/ugc/2508023918742009667/285BDC1882EFAE56A7E2F8408E98B4E5F7E663D6/',
  '$100D': 'http://cloud-3.steamusercontent.com/ugc/2508023918742008966/65C7D29DF5447332B07C9D6F905C574D9A0FABC5/',
}

const folders = fs.readdirSync(TTS_PATH);
Object.entries(chips)
  .map(([name, url]) => [name, url, folders.find((folder) => folder.startsWith(name))])
  .map(([name, url, folder]) => [name, url, `${folder}/${fs.readdirSync(`${TTS_PATH}/${folder}`)[0]}/Data.json`])
  .map(([name, url, file]) => [name, url, file, fs.readJSONSync(`${TTS_PATH}/${file}`)])
  .forEach(async ([name, url, file, data], i) => {
    data.CustomMesh.DiffuseURL = url;

    await fs.writeJson(`${TTS_PATH}/${file}`, data, { spaces: 2 });
  });

/*const folders = fs.readdirSync(TTS_PATH).filter((folder) => /^[0-9]+.*!/.test(folder));
console.log(folders);

folders.map((folder) => require(`${TTS_PATH}/${folder}/Data.json`))
  .forEach(async ({ Nickname: name, CustomMesh: { DiffuseURL: diffuse } }) => {
    name = name.toLowerCase();

    const res = await fetch(diffuse);
    if (res.ok && res.body) {
      const write = fs.createWriteStream(`${TTS_ASSETS_PATH}/${name}.png`);

      await new Promise((resolve, reject) => {
        res.body.pipe(write);
        res.body.on('error', reject);
        res.body.on('finish', resolve);
      });
    }
  });*/

/*const folders = fs.readdirSync(TTS_PATH).filter((folder) => folder.startsWith('$'))
  .map((folder) => `${folder}/${fs.readdirSync(`${TTS_PATH}/${folder}`)[0]}`);

folders.map((folder) => require(`${TTS_PATH}/${folder}/Data.json`))
  .forEach(async ({ Nickname: name, CustomMesh: { DiffuseURL: diffuse } }) => {
    const res = await fetch(diffuse);
    if (res.ok && res.body) {
      const write = fs.createWriteStream(`${TTS_ASSETS_PATH}/${name.replace('$', '')}.png`);

      await new Promise((resolve, reject) => {
        res.body.pipe(write);
        res.body.on('error', reject);
        res.body.on('finish', resolve);
      });
    }
  });*/
