import fs from 'fs'
import path from 'path'
import svelte from 'rollup-plugin-svelte'
import serve from 'rollup-plugin-serve'
import resolve from '@rollup/plugin-node-resolve'
import replace from '@rollup/plugin-replace'
import commonjs from '@rollup/plugin-commonjs'
import livereload from 'rollup-plugin-livereload'
import {terser} from 'rollup-plugin-terser'

const production = !process.env.ROLLUP_WATCH

const srcDir = path.join(path.dirname(__filename), "web")

function getDirectories(path) {
  return fs.readdirSync(path).filter(function(file) {
    return fs.statSync(path + "/" + file).isDirectory()
  })
}

// Allow absolute imports for anything inside web
const absolutize = () => ({
  resolveId(importee, importer) {
    const [first, ...rest] = importee.split(path.sep)
    const whitelist = getDirectories(srcDir)

    if (whitelist.indexOf(first) === -1) {
      return null
    }

    const fullPath = path.join(srcDir, importee).replace(/\.(js|svelte)$/, '')
    const jsPath = fullPath + '.js'
    const sveltePath = fullPath + '.svelte'

    if (fs.existsSync(jsPath)) {
      return jsPath
    } else if (fs.existsSync(sveltePath)) {
      return sveltePath
    }

    return null
  },
})

export default {
	input: 'web/main.js',
	output: {
		sourcemap: true,
		format: 'iife',
		name: 'app',
		file: 'public/bundle.js'
	},
	plugins: [
  	absolutize(),
  	replace({
    	process: JSON.stringify({
      	env: {
          PLAID_PUBLIC_KEY: process.env.PLAID_PUBLIC_KEY,
      	},
    	}),
  	}),
		svelte({
			dev: !production,
			css: css => css.write('public/bundle.css'),
		}),
		resolve({
			browser: true,
			dedupe: importee => importee === 'svelte' || importee.startsWith('svelte/'),
		}),
		commonjs(),
		!production && serve(),
		!production && livereload('public'),
		production && terser(),
	],
	watch: {
		clearScreen: false
	}
}















