week-days-checkbox
    .btn-group
        span.btn.btn-sm.btn-default(each='{ day, i in days }', class='{ btn-primary: parseInt(value[i]) }', onclick='{ click }') { day }

    script(type='text/babel').
        var self = this

        self.days = ['Пн.', 'Вт.', 'Ср.', 'Чт.', 'Пт.', 'Сб.', 'Вс.']
        self.value = '0000000'.split('')

        Object.defineProperty(self.root, 'value', {
            get() {
                return self.value.join('')
            },
            set(value) {
                if (!value) {
                    self.value = '0000000'.split('')
                } else {
                    self.value = value.toString().split('')
                }
            }
        })

        self.click = e => {
            self.value[e.item.i] = self.value[e.item.i] === '0' ? '1' : '0'
            var event = document.createEvent('Event')
            event.initEvent('change', true, true)
            self.root.dispatchEvent(event)
        }

        self.on('mount', () => {
            self.root.name = opts.name
        })