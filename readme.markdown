# Team Diagram Generator

Generates a (directed graph) [dot diagram][1] that is suitable for rendering
with [graphviz][2] from a specifically formatted json or yaml file.

[1]: https://en.wikipedia.org/wiki/DOT_(graph_description_language)
[2]: http://graphviz.org/

## Installation

```
npm i -g team-diagram-generator
```

## Usage

After installing, a command named `generate-team-diagram` will be available.

```
generate-team-diagram [opts] teams.json
```

See the built-in help for more details

```
generate-team-diagram --help
```

### With Graphviz

The `generate-team-diagram` command will output a `dot` digraph to stdout. You
will still need to perform a few more steps to actually render an image from the
diagram

[See the graphviz page on downloading][1] for details, but you should just be
able to install the `graphviz` package from your package manager of choice.

[1]: (http://www.graphviz.org/Download.php)

### Examples

```
# generate the diagram and save it to a file
generate-team-diagram teams.json > teams.dot

# assuming you installed the graphviz package (which provides the dot command, among others)
# generate a png from the diagram
dot -Tpng teams.dot > teams.png
```

```
# Generate an svg in one line
generate-team-diagram teams.json | dot -Tsvg > teams.svg
```

## Data Format

The input data should look like this:

```
[
  {
    name: 'student_name',
    wants_to_work_with: [
      'student_1',
      'student_2',
      ...
    ],
    doesnt_want_to_work_with: [
      'student_3',
      'student_4',
      ...
    ]
  },
  {
    ...
  }
]
```

In short, the data:

- must be an array of objects (dicts)
- each object must have properties for:
    - the individual's name
    - a list of preferred team members
    - a list of unprefered team members

The default key names for the keys described above are used in the example, but
if your data has different key names, you can set them through a cli argument.
See the built in help for more details.
