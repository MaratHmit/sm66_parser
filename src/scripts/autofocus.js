let autofocus = {
	autofocus() {
		let target = this.root.querySelector('[autofocus], [autofocus="autofocus"], [autofocus=""]')
		if (target && 'focus' in target && typeof target.focus === 'function') target.focus()
	}
}

riot.mixin(autofocus)