#!/usr/bin/env ruby

TRAC_DB_PATH = 'trac.db'
OUT_PATH = 'wiki'
GITHUB_WIKI_URL = '/seven1m/onebody/wikis/'

require 'sqlite3'

db = SQLite3::Database.new(TRAC_DB_PATH)
pages = db.execute('select name, text from wiki w2 where version = (select max(version) from wiki where name = w2.name);')

pages.each do |title, body|
  File.open(File.join(OUT_PATH, title.gsub(/\s/, '')), 'w') do |file|
    body.gsub!(/\{\{\{([^\n]+?)\}\}\}/, '<code>\1</code>')
    body.gsub!(/\{\{\{(.+?)\}\}\}/m, '<pre><code>\1</code></pre>')
    body.gsub!(/====\s(.+?)\s====/, 'h4. \1')
    body.gsub!(/===\s(.+?)\s===/, 'h3. \1')
    body.gsub!(/==\s(.+?)\s==/, 'h2. \1')
    body.gsub!(/=\s(.+?)\s=[\s\n]*/, '')
    body.gsub!(/\[(http[^\s\[\]]+)\s([^\[\]]+)\]/, '"\2":\1')
    body.gsub!(/\[([^\s]+)\s(.+)\]/, '"\2":' + GITHUB_WIKI_URL + '\1')
    body.gsub!(/([^"\/\!])(([A-Z][a-z0-9]+){2,})/, '\1[[\2]]')
    body.gsub!(/\!(([A-Z][a-z0-9]+){2,})/, '\1')
    body.gsub!(/'''(.+)'''/, '*\1*')
    body.gsub!(/''(.+)''/, '_\1_')
    body.gsub!(/^\s\*/, '*')
    body.gsub!(/^\s\d\./, '#')
    file.write(body)
  end
end