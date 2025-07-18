require 'yaml'

pubspec_path = '../../pubspec.yaml'
data = YAML.load_file(pubspec_path)
version = data['version'].split('+')
version_parts = version[0].split('.')
version_parts[2] = (version_parts[2].to_i + 1).to_s
new_version = version_parts.join('.') + '+' + version[1]
data['version'] = new_version
File.write(pubspec_path, data.to_yaml)