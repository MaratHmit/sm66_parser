| import './datatable.tag'
| import './bs-pagination.tag'

catalog-static

    .row(if='{ !opts.removeToolbar }')
        .col-md-12
            .form-inline.m-b-3
                .form-group(if='{ opts.add }')
                    button.btn.btn-primary(onclick='{ add }', type='button')
                        i.fa.fa-plus
                        |  Добавить
                #{'yield'}(from='toolbar')
                .form-group
                    button.btn.btn-danger(if='{ selectedCount }', onclick='{ remove }', title='Удалить', type='button')
                        i.fa.fa-trash { (selectedCount > 1) ? "&nbsp;" : "" }
                        span.badge(if='{ selectedCount > 1 }') { selectedCount }
    .row
        .col-md-12
            div(class='{ opts.responsive == "false" ? "" : "table-responsive" }')
                datatable(cols='{ opts.cols }', rows='{ items }', handlers='{ opts.handlers }', dblclick='{ opts.dblclick }',
                reorder='{ opts.reorder }')
                    #{'yield'}(from='body')

    .row(if='{ value.length > pages.limit }')
        .col-md-12
            bs-pagination(onselect='{ pages.change }', pages='{ pages.count }', page='{ pages.current }')

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.value = []
        self.items = []

        Object.defineProperty(self.root, 'value', {
            get() {
                return self.value || []
            },
            set(value) {
                self.value = value || []
                self.update()
            }
        })

        self.pages = {
            count: 0,
            current: 1,
            limit: 15,
            change(e) {
                self.pages.current = e.currentTarget.page
            }
        }

        self.getPageItems = () => {
            let count = self.value.length

            self.pages.count = Math.ceil(count / self.pages.limit)

            if (self.pages.current > self.pages.count)
                self.pages.current = self.pages.count

            self.pages.current = self.pages.current == 0 ? 1 : self.pages.current

            let offset = (self.pages.current - 1) * self.pages.limit
            let end = offset + self.pages.limit

            let items = self.value.filter((item, i) => (i > offset - 1 && i < end))

            return items
        }

        self.add = () => {
            if (typeof(opts.add) === 'function') {
                opts.add.bind(self)()
            }
        }

        self.remove = () => {
            self.selectedCount = 0

            let items = self.tags.datatable.getSelectedRows()

            self.value = self.value.filter(item => {
                return items.indexOf(item) === -1
            })

            let event = document.createEvent('Event')
            event.initEvent('change', true, true)
            self.root.dispatchEvent(event)

            if (typeof(opts.afterRemove) === 'function') {
                opts.afterRemove.bind(self)()
            }
        }

        self.on('update', () => {
            if ('rows' in opts) {
                if (self.value !== opts.rows)
                    self.selectedCount = 0

                self.value = opts.rows || []
                self.items = self.getPageItems() || []
            }
        })

        self.one('updated', () => {
            self.tags.datatable.on('row-selected', count => {
                self.selectedCount = count
                self.update()
            })
        })

        self.on('mount', () => {
            if (opts.name)
                self.root.name = opts.name
        })