import svelte from 'rollup-plugin-svelte'
import resolve from '@rollup/plugin-node-resolve'
import replace from '@rollup/plugin-replace'
import commonjs from '@rollup/plugin-commonjs'
import livereload from 'rollup-plugin-livereload'
import {terser} from 'rollup-plugin-terser'

const production = !process.env.ROLLUP_WATCH

export default {
	input: 'web/main.js',
	output: {
		sourcemap: true,
		format: 'iife',
		name: 'app',
		file: 'public/bundle.js'
	},
	plugins: [
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
		!production && livereload('public'),
		production && terser(),
	],
	watch: {
		clearScreen: false
	}
}















