| import debounce from 'lodash/debounce'
| import 'components/datatable.tag'
| import 'components/bs-pagination.tag'

catalog
    .row
        .col-md-12
            form(name='filters', onchange='{ find }')
                #{'yield'}(from='filters')

    .row
        .col-md-8.col-sm-6.col-xs-12
            .form-inline.m-b-2
                button.btn.btn-primary(if='{ opts.add }', onclick='{ opts.add }', type='button')
                    i.fa.fa-plus
                    |  Добавить
                button.btn.btn-success(if='{ opts.reload }', onclick='{ reload }', title='Обновить', type='button')
                    i.fa.fa-refresh
                button.btn.btn-danger(if='{ opts.remove && selectedCount }', onclick='{ remove }', title='Удалить', type='button')
                    i.fa.fa-trash { (selectedCount > 1) ? "&nbsp;" : "" }
                    span.badge(if='{ selectedCount > 1 }') { selectedCount }
                #{'yield'}(from='head')
        .col-md-4.col-sm-6.col-xs-12
            form.form-inline.text-right.m-b-2
                .form-group(if='{ opts.search }')
                    .input-group
                        input.form-control(name='search', type='text', placeholder='Поиск', onkeyup='{ find }')
                        span.input-group-btn
                            button.btn.btn-default(onclick='{ find }', type='submit')
                                i.fa.fa-search
                .form-group(if='{ !opts.disableLimit }')
                    select.form-control(value='{ pages.limit }', onchange='{ limitChange }')
                        option 15
                        option 30
                        option 50
                        option 100
                .form-group(if='{ !opts.disableColSelect }')
                    .btn-group(if='{ opts.cols && opts.cols.length }')
                        datatable-columns-select.dropdown(if='{ tags.datatable }', table='{ tags.datatable }', align='right')
    .row
        .col-md-12
            .table-responsive
                datatable(cols='{ opts.cols }', rows='{ items }', handlers='{ opts.handlers }', dblclick='{ opts.dblclick }',
                sortable='{ opts.sortable }', reorder='{ opts.reorder }', loader='{ loader }')
                    #{'yield'}(from='body')
                    #{'yield'}

    .row(show='{ !opts.disablePagination }')
        .col-md-12
            bs-pagination(name='paginator', onselect='{ pages.change }', pages='{ pages.count }', page='{ pages.current }')
            .pull-right(style='margin: 20px 0; height: 34px; line-height: 34px;')
                #{'yield'}(from='aggregation')
                strong Всего: { totalCount }

    style(scoped).
        :scope {
            position: relative;
            display: block;
        }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.totalCount = 0

        self.pages = {
            count: 0,
            current: 1,
            limit: 15,
            change: function (e) {
                self.pages.current = e.currentTarget.page
                self.reload()
            }
        }

        self.reload = e => {
            self.trigger('reload')

            self.loader = true
            self.update()

            var sort
            if (self.tags.datatable)
                sort = self.tags.datatable.getSortedColumn()

            var params = {}
            params.offset = (self.pages.current - 1) * self.pages.limit

            if (params.offset < 0) {
                params.offset = 0
            }

            params.limit = self.pages.limit
            
            if (sort) {
                params.sortBy = sort.name
                params.sortOrder = sort.dir.toLowerCase()
            }

            if (opts.search && self.search) {
                params.searchText = self.search.value
            }

            if (opts.filters && opts.filters instanceof Array)
                params.filters = opts.filters
            else
                params.filters = serializeFilters()

            if (opts.combineFilters && opts.filters && opts.filters instanceof Array) {
                params.filters = [...serializeFilters(), ...opts.filters]
            }

            API.request({
                object: opts.object,
                method: 'Fetch',
                cookie: opts.cookie || undefined,
                data: params,
                notFoundRedirect: false,
                success(response, xhr) {
                    if ('beforeSuccess' in opts && typeof(opts.beforeSuccess) === 'function')
                        opts.beforeSuccess.call(this, response, xhr)

                    self.totalCount = response.count
                    self.pages.count = Math.ceil(response.count / self.pages.limit)
                    if (self.pages.current > self.pages.count) {
                        self.pages.current = self.pages.count
                    }
                    self.items = response.items ? response.items : []
                    self.tags.paginator.update({pages: self.pages.count, page: self.pages.current})
                    self.update()
                },
                error(response, xhr) {
                    self.pages.count = 0
                    self.pages.current = 0
                    self.items = []
                    self.tags.paginator.update({pages: self.pages.count, page: self.pages.current})
                },
                complete(response, xhr) {
                    self.update({
                        selectedCount: 0,
                        loader: false,
                        isFind: false
                    })
                }
            })
        }

        self.remove = e => {
            var _this = this,
                itemsToRemove = []

            _this.items.forEach((item, i, arr) => {
                if (item.__selected__ == true)
                    itemsToRemove.push(item.id)
            })

            if (opts.remove)
                opts.remove.bind(this, e, itemsToRemove, self)()
        }

        self.find = debounce(e => {
            self.pages.current = 1
            self.reload()
        }, 400)

        self.limitChange = e => {
            if (opts.store && opts.store.trim() !== '') {
                let store = JSON.parse(localStorage.getItem(`shop24_${opts.store}`) || '{}')
                store.limit = e.target.value
                localStorage[`shop24_${opts.store}`] = JSON.stringify(store)
            }
            self.pages.limit = e.target.value
            self.reload()
        }

        var serializeFilters = () => {
            if (!self.filters) return

            var result = []
            var items = self.filters.querySelectorAll('[data-name]')

            for (var i = 0; i < items.length; i++) {
                var item = {}
                var required = items[i].getAttribute('data-required')
                var type = items[i].type ? items[i].type.toLowerCase() : ''

                var bool = items[i].getAttribute('data-bool')

                if (bool && bool.split(',').length === 2)
                    bool = bool.split(',')
                else
                    bool = false

                if (type === 'checkbox') {
                    let value = items[i].checked

                    if (bool) {
                        let i = value ? 0 : 1
                        item.value = bool[i]
                    } else {
                        item.value = items[i].checked
                    }
                }

                if (type != 'checkbox') {
                    item.value = items[i].value
                }

                if (item) {
                    item.field = items[i].getAttribute('data-name')
                    if (items[i].getAttribute('data-sign'))
                        item.sign = items[i].getAttribute('data-sign')
                    else
                        item.sign = '='
                    if (items[i].getAttribute('data-type'))
                        item.type = items[i].getAttribute('data-type')
                }

                if (type === 'checkbox' && bool instanceof Array) {
                    if (required || item.value != bool[1])
                        result.push(item)
                } else {
                    if (required || item.value)
                        result.push(item)
                }
            }

            if (result.length)
                return result
            else
                return []
        }

        var parseFilters = (filters) => {
            if (!filters && !(filters instanceof Array))
                return

            let result = filters.map(item => {
                let {field, sign, value, type} = item

                if (type == 'bool')
                    value = value === '1'
                else if (typeof(value) !== 'boolean')
                    value = `'${value}'`

                return `[${field}]${sign}${value}`
            })

            return result.join(` AND `)
        }

        self.on('mount', () => {
            if (opts.store && opts.store.trim() !== '') {
                let store = JSON.parse(localStorage.getItem(`shop24_${opts.store}`))
                if (store) {
                    if (store.limit)
                        self.pages.limit = store.limit

                    if (opts.cols && store.cols && typeof store.cols === 'object') {
                        var columns = Object.keys(store.cols)
                        opts.cols.forEach(item => {
                            if (columns.indexOf(item.name) !== -1)
                                item.hidden = true
                        })
                    }

                    if (store.sort && typeof store.sort === 'object') {
                        var column = Object.keys(store.sort)
                        if (column.length > 0)
                            opts.cols.forEach(item => {
                                if (item.name === column[0])
                                    item.dir = store.sort[column[0]]
                            })
                    }
                }
            }
            self.reload()
        })

        self.one('updated', () => {
            self.tags.datatable.on('row-selected', count => {
                self.selectedCount = count
                self.update()
            })
            self.tags.datatable.on('sort', () => {
                let store = JSON.parse(localStorage.getItem(`shop24_${opts.store}`) || '{}')

                store.sort = {}

                let sort = self.tags.datatable.getSortedColumn()

                store.sort[sort.name] = sort.dir
                localStorage[`shop24_${opts.store}`] = JSON.stringify(store)
                self.reload()
            })
            self.tags.datatable.on('column-toggle', (name, hidden) => {
                let store = JSON.parse(localStorage.getItem(`shop24_${opts.store}`) || '{}')
                if (!('cols' in store))
                    store.cols = {}

                if (!hidden) {
                    store.cols[name] = hidden
                } else {
                    delete store.cols[name]
                }

                localStorage[`shop24_${opts.store}`] = JSON.stringify(store)
            })

        })

        self.on('update', () => {
            if (opts.handlers)
                self.handlers = opts.handlers
        })