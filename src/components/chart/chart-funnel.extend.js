var helpers = Chart.helpers

Chart.defaults.funnel.sort = undefined
Chart.controllers.funnel.prototype.update = function(reset) {
    var me = this;
    var chart = me.chart,
        chartArea = chart.chartArea,
        opts = chart.options,
        meta = me.getMeta(),
        elements = meta.data,
        borderWidth = opts.elements.borderWidth || 0,
        availableWidth = chartArea.right - chartArea.left - borderWidth * 2,
        availableHeight = chartArea.bottom - chartArea.top - borderWidth * 2;

    // top and bottom width
    var bottomWidth = availableWidth,
        topWidth = (opts.topWidth < availableWidth ? opts.topWidth : availableWidth) || 0;
    if (opts.bottomWidth) {
        bottomWidth = opts.bottomWidth < availableWidth ? opts.bottomWidth : availableWidth;
    }

    // percentage calculation and sort data
    var sort = opts.sort,
        dataset = me.getDataset(),
        valAndLabels = [],
        visiableNum = 0,
        dMax = 0;
    helpers.each(dataset.data, function (val, index) {
        var backgroundColor = helpers.getValueAtIndexOrDefault(dataset.backgroundColor, index),
            hidden = elements[index].hidden;
        //if (!elements[index].hidden) {
        valAndLabels.push({
            hidden: hidden,
            orgIndex: index,
            val: val,
            backgroundColor: backgroundColor,
            borderColor: helpers.getValueAtIndexOrDefault(dataset.borderColor, index, backgroundColor),
            label: helpers.getValueAtIndexOrDefault(dataset.label, index, chart.data.labels[index])
        });
        //}
        if (!elements[index].hidden) {
            visiableNum++;
            dMax = val > dMax ? val : dMax;
        }
    });
    var dwRatio = bottomWidth / dMax
    var sortedDataAndLabels = !sort ? valAndLabels : valAndLabels.sort(
        sort === 'asc' ?
            function (a, b) {
                return a.val - b.val;
            } :
            function (a, b) {
                return b.val - a.val;
            }
    );
    // For render hidden view
    // TODO: optimization....
    var _viewIndex = 0;
    helpers.each(sortedDataAndLabels, function (dal, index) {
        dal._viewIndex = !dal.hidden ? _viewIndex++ : -1;
    });

    // Elements height calculation
    var gap = opts.gap || 0,
        elHeight = (availableHeight - ((visiableNum - 1) * gap)) / visiableNum;

    // save
    me.topWidth = topWidth;
    me.dwRatio = dwRatio;
    me.elHeight = elHeight;
    me.sortedDataAndLabels = sortedDataAndLabels;
    me.maxVal = Math.max.apply(null, sortedDataAndLabels.map(function (value) {
        return !value.hidden ? value.val : undefined
    }).filter(function(value){ return value }));
    me.minVal = Math.min.apply(null, sortedDataAndLabels.map(function (value) {
        return !value.hidden ? value.val : undefined
    }).filter(function(value){ return value }));
    me.chartWidth = availableWidth;
    me.deltaVal = (me.maxVal - ((opts.minWidth || 10) / me.chartWidth * me.maxVal)) || 0;

    helpers.each(elements, function (trapezium, index) {
        me.updateElement(trapezium, index, reset);
    }, me);
}

Chart.controllers.funnel.prototype.updateElement = function updateElement(trapezium, index, reset) {
    var me = this,
        chart = me.chart,
        chartArea = chart.chartArea,
        opts = chart.options,
        sort = opts.sort,
        dwRatio = me.dwRatio,
        elHeight = me.elHeight,
        gap = opts.gap || 0,
        minWidth = opts.minWidth || 10,
        minValue = me.minVal,
        chartWidth = me.chartWidth,
        deltaValue = me.deltaVal,
        borderWidth = opts.elements.borderWidth || 0;

    // calculate x,y,base, width,etc.
    var x, y, x1, x2,
        elementType = 'isosceles',
        elementData = me.sortedDataAndLabels[index], upperWidth, bottomWidth,
        viewIndex = elementData._viewIndex < 0 ? index : elementData._viewIndex,
        base = chartArea.top + (viewIndex + 1) * (elHeight + gap) - gap;

    if (sort === 'asc') {
        // Find previous element which is visible
        var previousElement = helpers.findPreviousWhere(me.sortedDataAndLabels,
            function (el) {
                return !el.hidden;
            },
            index
        );
        upperWidth = nextElement ? (chartWidth - minWidth) * ((previousElement.val * (1 - minWidth / chartWidth)) / deltaValue) + minWidth : me.topWidth;
        bottomWidth = (chartWidth - minWidth) * ((elementData.val * (1 - minWidth / chartWidth)) / deltaValue) + minWidth;
    } else  {
        var nextElement = helpers.findNextWhere(me.sortedDataAndLabels,
            function (el) {
                return !el.hidden;
            },
            index
        );
        upperWidth = (chartWidth - minWidth) * ((elementData.val * (1 - minWidth / chartWidth)) / deltaValue) + minWidth;
        bottomWidth = nextElement ? (chartWidth - minWidth) * ((nextElement.val * (1 - minWidth / chartWidth)) / deltaValue) + minWidth : me.topWidth;
    }

    y = chartArea.top + viewIndex * (elHeight + gap);
    if (opts.keep === 'left') {
        elementType = 'scalene';
        x1 = chartArea.left + upperWidth / 2;
        x2 = chartArea.left + bottomWidth / 2;
    } else if (opts.keep === 'right') {
        elementType = 'scalene';
        x1 = chartArea.right - upperWidth/ 2;
        x2 = chartArea.right - bottomWidth / 2;
    } else {
        x = (chartArea.left + chartArea.right) / 2;
    }

    helpers.extend(trapezium, {
        // Utility
        _datasetIndex: me.index,
        _index: elementData.orgIndex,

        // Desired view properties
        _model: {
            type: elementType,
            y: y,
            base: base > chartArea.bottom ? chartArea.bottom : base,
            x: x,
            x1: x1,
            x2: x2,
            upperWidth: (reset || !!elementData.hidden) ? 0 : upperWidth,
            bottomWidth: (reset || !!elementData.hidden) ? 0 : bottomWidth,
            borderWidth: borderWidth,
            backgroundColor: elementData && elementData.backgroundColor,
            borderColor: elementData && elementData.borderColor,
            label: elementData && elementData.label
        }
    });

    trapezium.pivot();
}