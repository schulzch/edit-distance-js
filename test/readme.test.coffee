should = require('chai').should()
marked = require 'marked'
ed = require '../src/index'
fs = require 'fs'

parseCodeBlocks = (tokens) ->
	tokens = tokens.filter (token) -> token.type is 'code' and token.lang is 'javascript'
	return tokens.map (token) -> token.text

describe 'README.md', ->
	readme = fs.readFileSync __dirname + '/../README.md', 'utf8'
	codeBlocks = parseCodeBlocks(marked.lexer(readme))

	for codeBlock, index in codeBlocks.slice(1)
		do (codeBlock, index) ->
			it 'example no. ' + (index + 1) + ' should work', ->
				oldConsoleLog = console.log
				console.log = ->
				try
					eval codeBlock
				catch e
					throw e
				finally 
					console.log = oldConsoleLog
