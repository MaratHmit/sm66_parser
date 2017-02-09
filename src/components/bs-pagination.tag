bs-pagination

    .form-inline.pagination
        .btn-group(onclick='{ prev }')
            button.btn.btn-default(class='{ disabled: page <= 1  }', type='button')
                a.fa.fa-angle-left
        span  стр.
        .btn-group
            input(type='text', class='form-control',
            style='width: 64px; text-align: right;',
            value='{ parseInt(page) }', onkeyup='{ submit }', onchange='{ stopPropagation }', onselect='{ stopPropagation }')
        span  из
        strong  { parseInt(pages) }
        .btn-group(onclick='{ next }')
            button.btn.btn-default(class='{ disabled: page >= pages }', type='button')
                a.fa.fa-angle-right

    style(scoped).
        :scope {
            display: inline-block;
            position: relative;
        }

    script(type='text/babel').
        var self = this

        self.page_array = () => {
            const arr = []
            const current = self.page, count = self.pages

            if (count > 10) {
                let start = current - 5, stop = current + 5

                const dstart = 1 - (current - 5)
                const dstop = count - (current + 5)

                const astop = dstart > 0 ? Math.abs(dstart) : 0
                const astart = dstop < 0 ? Math.abs(dstop) : 0

                start = start - astart > 0 ? start - astart : start > 0 ? start : 1
                stop = stop + astop <= count ? stop + astop : stop <= count ? stop : count

                for (var i = start; i <= stop; i++)
                    arr.push(i)
            } else {
                for (var i = 0; i < count; i++)
                    arr.push(i + 1)
            }

            return arr
        }

        self.first = e => {
            if (self.page > 1) {
                self.root.page = self.page = 1
                $(self.root).trigger('select')
            }
        }

        self.prev = e => {
            if (self.page > 1) {
                self.root.page = --self.page
                $(self.root).trigger('select')
            }
        }

        self.next = e => {
            if (self.page < self.pages) {
                self.root.page = ++self.page
                $(self.root).trigger('select')
            }
        }

        self.last = e => {
            if (self.page < self.pages) {
                self.root.page = self.page = self.pages
                $(self.root).trigger('select')
            }
        }

        self.select = e => {
            self.root.page = self.page = e.item.item
            $(self.root).trigger('select')
        }

        self.submit = e => {
            if (e.keyCode === 13) {
                let page = parseInt(e.target.value);
                if (typeof(page) === 'number') {
                    if (page > self.pages)
                        page = self.pages

                    if (page < 1)
                        page = 1

                    self.root.page = self.page = page
                    $(self.root).trigger('select')
                }
            }
        }

        self.stopPropagation = e => {
            e.stopPropagation()
            e.stopImmediatePropagation()
        }

        self.on('update', () => {
            self.pages = parseInt(opts.pages) || 0
            self.root.page = self.page = parseInt(opts.page) || 1
        })