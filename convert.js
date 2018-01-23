/**
 * Converts a json object whose keys are student names to an array of objects
 * that the `app` script can handle
 */
const fs = require('fs');

const students = JSON.parse(fs.readFileSync('./niagara.json').toString());

const converted = Object.keys(students).map((student) => {
  return Object.assign(students[student], {name: student});
})

console.log(JSON.stringify(converted, null, 2));
