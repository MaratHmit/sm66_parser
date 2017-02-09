| import Chart from 'chart.js/src/chart.js'
| import 'chartjs-funnel/src/chart.funnel.js'
| import './chart-funnel.extend.js'
chart
    canvas

    style(scoped).
        :scope {
            display: inline-block;
            width: 100%;
        }

    script(type='text/babel').
        var self = this
        self.chart = null

        Chart.defaults.global.responsive = true

        self.one('updated', () => {
            drawChart()

            self.on('updated', () => {
                destroyChart()
                drawChart()
            })
        })

        self.on('loaded', c => {
            this.on('unmount', () => {
                c.destroy()
            })
        })

        const chartTypes = ['bar', 'line', 'radar', 'polar', 'pie', 'doughnut', 'funnel']

        const drawChart = () => {
            if (!opts.data) opts.data = {labels:[], datasets:[]}
            if (!opts.options) opts.options = {}

            opts.options.animation = {duration: 0}

            let ctx = self.root.querySelector('canvas').getContext('2d')
            self.chart = new Chart(ctx, {
                type: chartTypes.indexOf(opts.type) !== -1 ? opts.type : 'bar',
                data: opts.data,
                options: opts.options
            })

            self.trigger('loaded', self.chart)
        }

        const destroyChart = () => {
            self.chart.destroy()
        }
