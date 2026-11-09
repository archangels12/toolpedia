'use strict';

const { existsSync, readdirSync } = require('node:fs');
const { join } = require('node:path');

// Chrome 앱이 없으면 빌드용으로 받아 둔 headless chrome(.chrome/, scripts/prerender.mjs 와 같은 것)을 쓴다
function localChrome() {
	if (process.env.CHROME_PATH) return process.env.CHROME_PATH;
	const base = join(__dirname, '.chrome', 'chrome-headless-shell');
	if (!existsSync(base)) return undefined;
	const dirs = (p) =>
		readdirSync(p, { withFileTypes: true })
			.filter((d) => d.isDirectory())
			.map((d) => d.name);
	for (const version of dirs(base))
		for (const dir of dirs(join(base, version))) {
			const exe = join(
				base,
				version,
				dir,
				'chrome-headless-shell',
			);
			if (existsSync(exe)) return exe;
		}
	return undefined;
}

const chrome = localChrome();

if (typeof module !== 'undefined') {
	module.exports = {
		test_page: 'tests/index.html?hidepassed',
		disable_watching: true,
		launch_in_ci: ['Chrome'],
		launch_in_dev: ['Chrome'],
		browser_start_timeout: 120,
		...(chrome ? { browser_paths: { Chrome: chrome } } : {}),
		browser_args: {
			Chrome: {
				ci: [
					process.env.CI ? '--no-sandbox' : null,
					'--headless',
					'--disable-dev-shm-usage',
					'--disable-software-rasterizer',
					'--mute-audio',
					'--remote-debugging-port=0',
					'--window-size=1440,900',
				].filter(Boolean),
			},
		},
	};
}
