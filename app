#!/usr/bin/env node
/* vi: set ft=javascript : */

const helpMessage = `
generate-team-diagram <json-file> [options]

  genrates a graphviz dot diagram from a json file

  expects the json file to have the following format:

    [
      {
        name: 'student_name',
        wants_to_work_with: [
          'student_1',
          'student_2',
          ...
        ]
      },
      {
        ...
      }
    ]
`;

const fs = require('fs');
const yaml = require('js-yaml');
const {execSync} = require('child_process');

const options = {
  'preferences-key': {
    description: 'key name for teamate preferences',
    default: 'wants_to_work_with',
  },
  'unpreferences-key': {
    description: 'key name for teamate unpreferences',
    default: 'doesnt_want_to_work_with',
  },
  'name-key': {
    description: 'key name for student name',
    default: 'name',
  },
  'concentrate': {
    description: 'whether or not to concentrate the edges of the diagram',
    default: true,
  },
  'rankdir': {
    description: 'rankdir for the resulting diagram',
    default: 'TB',
  },
  'show-preferences': {
    description: 'whether or not to show the preferences in the output diagram',
    default: true,
  },
  'show-unpreferences': {
    description: 'whether or not to show the unpreferences in the output diagram',
    default: true,
  },
};

const argv = require('yargs')
  .options(options)
  .example('generate-team-diagram --no-concentrate teams.json')
  .help()
  .alias('h', 'help')
  .argv

// console.log(argv);
// process.exit(0);

const [filename] = argv._;

if (typeof filename === 'undefined') {
  console.log('You must pass a filename. (see --help)');
  process.exit(1);
}

const {
  nameKey,
  preferencesKey,
  unpreferencesKey,
  rankdir,
  showUnpreferences,
  showPreferences
} = argv;
const unpreferenceFormat = '[fillcolor = red, color = red]';

const validateJson = (students) => {
  if (! Array.isArray(students)) {
    return { valid: false, message: 'Excpected it to be an array' }
  }
  if (! students.every(s => typeof s.name === 'string')) {
    return { valid: false, message: 'Expected every student to have a name property that is a string' }
  }
  for (let student of students) {
    if (! Array.isArray(student[preferencesKey])) {
      return { valid: false, message: `[${student.name}] - Expected student[${preferencesKey}] to be an array` }
    }
    if (! Array.isArray(student[unpreferencesKey])) {
      return { valid: false, message: `[${student.name}] - Expected student[${unpreferencesKey}] to be an array` }
    }
    if (! student[unpreferencesKey].every(n => typeof n === 'string')) {
      return { valid: false, message: `[${student.name}] - Expected student[${unpreferencesKey}] to be an array of strings` }
    }
    if (! student[preferencesKey].every(n => typeof n === 'string')) {
      return { valid: false, message: `[${student.name}] - Expected student[${preferencesKey}] to be an array of strings` }
    }
  }
  return { valid: true, message: '' }
}

const readJson = (filename) => {
  const fileContents = fs.readFileSync(filename).toString();
  return JSON.parse(fileContents);
}

const readYaml = (filename) => {
  const contents = fs.readFileSync(filename).toString();
  return yaml.safeLoad(contents);
}

const codifyName = name => name.toLowerCase().replace(/\s/g, '_');

let students = filename.endsWith('json') ?
  readJson(filename) :
  readYaml(filename);

// if each entry doesn't specify preferences or unpreferences, we'll set them to
// an empty array
students = students.map(student => Object.assign({
  [preferencesKey]: [],
  [unpreferencesKey]: [],
}, student));

let validation = validateJson(students);

if (! validation.valid) {
  console.log('Invalid json format. Error:');
  console.log(validation.message);
  console.log()
  process.exit(1);
}

const formattedStudents = students.map((student) => {
  const displayName = student[nameKey];
  const lname = codifyName(student[nameKey]);

  const relations = student[preferencesKey].length > 0
    ? `${lname} -> {${student[preferencesKey].map(codifyName).join(', ')}}`
    : '';

  let unpreferences;
  if (typeof student[unpreferencesKey] === 'undefined') {
    unpreferences = [];
  } else {
    unpreferences = student[unpreferencesKey].length > 0
      ? `${lname} -> {${student[unpreferencesKey].map(codifyName).join(', ')}} ${unpreferenceFormat}`
      : '';
  }

  return {
    displayName,
    name: lname,
    relations,
    unpreferences,
  };
});

const displayNames = formattedStudents.map((student) => {
  return `${student.name} [label="${student.displayName}"]`;
});

// filter to remove empty strings
const relations = formattedStudents.map(student => student.relations)
  .filter(relations => relations.length > 0);
const unpreferences = formattedStudents.map(student => student.unpreferences)
  .filter(unpreferences => unpreferences.length > 0);

console.log(`
digraph {
  rankdir=${rankdir}
  ${argv.concentrate ? 'concentrate=true\n' : ''}
  ${displayNames.join('\n  ')}

  ${showPreferences ? relations.join('\n  ') : ''}

  ${showUnpreferences ? unpreferences.join('\n  ') : ''}
}
`);

