package;

import kha.System;

class Main {
	public static function main() {
		System.init({title: "Project", width: 400, height: 400}, function () {
			new Project();
		});
	}
}
