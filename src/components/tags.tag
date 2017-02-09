tags
    .tags-item(each="{ item, i in items }", if="{ item !== null }")
        .tags-item-body
            span.title(title='{ item.title }') { item.title }
            span.close(onclick='{ remove }') &times;

    style(scoped).
        /*.tags {
            display: block;
            position: relative;
            height: auto;
            padding-bottom: 0;
            padding-left: 6px;
            min-height: 40px;
        }*/

        .tags-item {
            display: inline-block;
            max-width: 250px;
            color: #333;
            background-color: #fff;
            border-radius: 4px;
            padding: 2px 4px;
            margin-right: 4px;
            margin-bottom: 6px;
            border: 1px solid #ccc;
        }

        .tags-item:hover {
            border: 1px solid #aaa;
        }

        .tags-item-body {
            display: block;
            position: relative;
        }

        .tags-item-body .title {
            display: inline-block;
            overflow: hidden;
            text-overflow: ellipsis;
            vertical-align: top;
            max-width: 225px;
            white-space: nowrap;
            cursor: default;
        }

        .tags-item-body .close {
            line-height: 0.85;
        }

    script(type='text/babel').
        var self = this

        self.items = []

        Object.defineProperty(self.root, 'value', {
            get() {
                return self.items
            },
            set(value) {
                self.items = value
            }
        })

        self.remove = function () {
            self.items.splice(this.i, 1)
        }

        self.add = function (item) {
            for (var i = 0; i < self.items.length; i++)
                if (self.items[i].id)
                    if (self.items[i].id == item.id) return

            if (self.items instanceof Array) {
                self.items.push(item)
            } else {
                self.items = []
                self.items.push(item)
            }
        }

        var sortableOption = {
            onEnd: function (evt) {
                self.items.splice(evt.newIndex, 0, self.items.splice(evt.oldIndex, 1)[0])
                var temp = self.items
                self.items = []
                self.update()
                self.items = temp
                self.update()
            }
        }

        self.on('mount', function () {
            Sortable.create(self.root, sortableOption)
        })