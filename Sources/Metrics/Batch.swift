//
//  Batch.swift
//  StatsdClient
//
//  Created by Khoi Lai on 2/26/18.
//  Copyright © 2018 StatsdClient. All rights reserved.
//

import Foundation

public struct Batch: Metric {

    public var metricData: String

    init(metrics: Metric...) {
        metricData = ""
        for (index, metric) in metrics.enumerated() {
            metricData += index == metrics.count - 1 ? "\(metric.metricData)" : "\(metric.metricData)\n"
        }
    }
}
