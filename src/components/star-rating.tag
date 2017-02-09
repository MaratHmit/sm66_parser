| import 'font-awesome/css/font-awesome.min.css'

star-rating
    div.star.fa(each='{ item, i in items }', class='{ size ? sizes[size] : "fa-lg" }{ item.selected ? " fa-star" : " fa-star-o" }'
    onclick='{ select }', no-reorder)

    style(scoped).
        :scope {
            position: relative;
            display: block;
        }

        :scope.inline {
            display: inline-block;
        }

        .star {
            display: inline-block;
            white-space: nowrap;
            cursor: pointer;
            color: #ffaa00;
        }

        .star:hover {
            text-shadow: 0 0 3px #885500;
        }

    script(type='text/babel').
        var self = this

        self.value = 0

        self.sizes = {
            small: '',
            normal: 'fa-lg',
            middle: 'fa-2x',
            large: 'fa-3x',
            big: 'fa-4x'
        }

        Object.defineProperty(self.root, 'value', {
            get() {
                return self.value
            },
            set(value) {
                self.value = value
                self.update()
            }
        })

        self.items = []

        self.select = e => {
            self.value = e.item.i + 1

            let event = document.createEvent('Event')
            event.initEvent('change', true, true)
            self.root.dispatchEvent(event)

            self.trigger('selected', e.item.i)
        }

        self.on('update', () => {
            if (opts.value)
                self.value = parseInt(opts.value)

            if (opts.name)
                self.root.name = opts.name

            if (opts.size)
                self.size = opts.size

            self.items = []

            for (let i = 0; i < opts.count; i++) {
                let selected = (i < self.value)
                self.items.push({selected: selected})
            }
        })