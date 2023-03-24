const path = require('path')
const solc = require('solc');
const fs = require('fs-extra')

//to remove the build folder
const buildPath = path.resolve(__dirname,'build');
fs.removeSync(buildPath);

//read campaign.sol from contracts folder
const campaignPath = path.resolve(__dirname,'contracts','Campaign.sol')
const source = fs.readFileSync(campaignPath,'utf-8')
//compile both contracts with solidity compiler
var input = {
    language: 'Solidity',
    sources: {
        'Campaign.sol' : {
            content: source
        }
    },
    settings: {
        outputSelection: {
            '*': {
                '*': [ '*' ]
            }
        }
    }
  };
  var output = JSON.parse(solc.compile(JSON.stringify(input)))
//write output in build directory
fs.ensureDirSync(buildPath);
for(let contract in output){
    fs.outputJSONSync(
        path.resolve(buildPath,contract.replace(':','aaaa')+'.json'),
        output[contract],
        console.log(output.id)
    )
}