
| import once from 'lodash/once'

autocomplete
	
	input(class='{ "open": isOpen && !opts.disabled }', type='text', onfocus='{ focus }', oninput='{ filterOptions }',
	onchange='{ stop }' ,value='{ filterValue }')
	div.results(show='{ isOpen && !opts.disabled }', onchange='return false;')
		div.text(if='{ parseInt(opts.minSymbols) ? filterValue.length < parseInt(opts.minSymbols) : false }')
			| Введите не менее { parseInt(opts.minSymbols) } символ{parseInt(opts.minSymbols) == 1 ? 'а' : 'ов' }
		ul(if='{ parseInt(opts.minSymbols) ? filterValue.length > (parseInt(opts.minSymbols) - 1) : true }')
			li(each='{ item, i in filter() }', onclick='{ itemClick }', no-reorder)
				#{'yield'}

	style(scoped).
		:scope {
			display: block;
			width: 100%;
			vertical-align: middle;
			height: 34px;
			position: relative;
		}
		
		:scope > input {
			padding: 6px 12px;
			font-size: 14px;
			border: 1px solid #ccc;
			border-radius: 4px;
			background-color: #fff;
		}

		.text {
			margin: 6px 12px;
			font-size: 14px;
			background-color: #fff;
		}

		:scope > input.open {
			border: 1px solid #66afe9;
			border-radius: 4px 4px 0 0;
			outline: 0;
			-webkit-box-shadow: inset 0 1px 1px rgba(0,0,0,.075),0 0 8px rgba(102,175,233,.6);
			box-shadow: inset 0 1px 1px rgba(0,0,0,.075),0 0 8px rgba(102,175,233,.6);
		}

		:scope .results {
			outline: 0;
			-webkit-box-shadow: inset 0 1px 1px rgba(0,0,0,.075),0 0 8px rgba(102,175,233,.6);
			box-shadow: inset 0 1px 1px rgba(0,0,0,.075),0 0 8px rgba(102,175,233,.6);
			border-radius: 0 0 4px 4px;
			z-index: 10;
			position: absolute;
			background-color: #fff;
			background-image: none;
			border-left: 1px solid #66afe9;
			border-right: 1px solid #66afe9;
			border-bottom: 1px solid #66afe9;
			left: 0;
			right: 0;
		}

		:scope .results > .text {
			display: block;
			position: relative;
			padding: 4px;
		}

		:scope .results > .text input {
			border: 1px solid #ccc;
			width: 100%;
			padding: 4px;
			height: 28px;
		}

		:scope ul {
			list-style: none;
			margin: 0;
			padding: 6px 0px;
			font-size: 14px;
			overflow-x: hidden;
			overflow-y: auto;
			max-height: 200px;
		}

		:scope ul li {
			padding: 4px 12px;
			cursor: pointer;
		}

		:scope ul li:hover {
			color: #fff;
			background-color: #66afe9;
		}

		.form-inline :scope {
			display: inline-block;
			width: auto;
			vertical-align: middle;
		}

	script(type='text/babel').
		var self = this
		self.filterValue = ''

		self.value = opts.value

		Object.defineProperty(self.root, 'value', {
			get() {
				return self.value
			},
			set(value) {
				self.value = value
				self.update()
			}
		})
		
		const handleClickOutside = e => {
			if (!self.root.contains(e.target)) self.close()
			self.update()
		}

		self.stop = e => {
			e.stopPropagation()
		}

		self.open = () => {
			self.isOpen = true
			self.trigger('open')
		}

		self.close = () => {
			self.isOpen = false
			self.trigger('close')
		}

		self.focus = (e) => {
			self.open()
		}
		
		self.filterOptions = (e) => {
			e.stopPropagation()
			if (e.target.value == '') {
				self.value = undefined
				var event = document.createEvent('Event')
				event.initEvent('change', true, true)
				self.root.dispatchEvent(event)
			}
			self.filterValue = e.target.value
		}

		self.filter = () => {
			let value = self.filterValue

			if (parseInt(opts.minSymbols))
				if (value.length < parseInt(opts.minSymbols))
					return []
			else if (value == '')
				return self.data

			return self.data.filter(item => {
				return item[self.valueField].toLowerCase().indexOf(value.toLowerCase()) !== -1
			})
		}

		self.itemClick = (e) => {
			self.value = e.item.item[self.idField]
			self.filterValue = e.item.item[self.valueField]
			self.close()
			var event = document.createEvent('Event')
			event.initEvent('change', true, true)
			self.root.dispatchEvent(event)
		}

		self.one('mount', () => {
			self.root.name = opts.name
			self.close()
			document.addEventListener('mousedown', handleClickOutside)
		})

		self.one('update', () => {
			if (opts.loadData)
				self.firstLoadData = once(opts.loadData.bind(this))
		})

		this.on('unmount', () => {
			document.removeEventListener('mousedown', handleClickOutside)
		})

		self.on('update', () => {
			if (!opts.disabled) {
				if (opts.loadData)
					self.loadData = opts.loadData.bind(this)

				if (opts.data && !opts.loadData)
					self.data = opts.data || []

				self.idField = opts.idField || 'id'
				self.valueField = opts.valueField || 'value'

				if (opts.loadData)
					self.firstLoadData()
			}
		})

		self.on('open', () => {
			if (self.loadData && !opts.disabled)
				self.loadData()
		})