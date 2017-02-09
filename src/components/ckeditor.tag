ckeditor
    textarea(id='ck_{ _riot_id }')
    script(type='text/babel').
        var self = this

        self.value = ''

        Object.defineProperty(self.root, 'value', {
            get: function () {
                return self.value
            },
            set: function (value) {
                self.value = value
            }
        })

        self.one('updated', function() {
            var instance = CKEDITOR.replace('ck_' + self._riot_id, {
                extraPlugins: 'divarea'
            })

            instance.on('change', function () {
                var event = document.createEvent('Event')
                event.initEvent('change', true, true)
                self.root.dispatchEvent(event);
            })

            instance.on('instanceReady', function (event) {
                instance.setData(self.value)
                instance.resetUndo()

                Object.defineProperty(self, 'value', {
                    get: function () {
                        return instance.getData()
                    },
                    set: function (value) {
                        if (value == null || value == undefined)
                            value = ''
                        if (instance.getData() !== value) {
                            instance.setData(value)
                            instance.resetUndo()
                        }
                    }
                })
            })
        })

        self.on('mount', function () {
            self.root.name = opts.name
        })