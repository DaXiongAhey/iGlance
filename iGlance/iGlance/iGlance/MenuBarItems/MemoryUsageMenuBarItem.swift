//
//  MemoryUsageMenuBarItem.swift
//  iGlance
//
//  Created by Dominik on 12.02.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Foundation
import CocoaLumberjack

class MemoryUsageMenuBarItem: MenuBarItem {
    let barGraph: BarGraph
    let lineGraph: LineGraph

    override init() {
        let maxMemValue = Double(AppDelegate.systemInfo.memory.getTotalMemorySize())
        self.barGraph = BarGraph(maxValue: maxMemValue)
        let graphWidth = AppDelegate.userSettings.settings.memory.usageLineGraphWidth
        self.lineGraph = LineGraph(maxValue: maxMemValue, imageWidth: graphWidth)

        super.init()
    }

    // MARK: -
    // MARK: Protocol Implementations

    func update() {
        let usage = AppDelegate.systemInfo.memory.getMemoryUsage()
        updateMenuBarIcon(memoryUsage: usage)
    }

    // MARK: -
    // MARK: Private Functions

    /**
     * Updates the icon of the menu bar item. This function is called during every update interval.
     */
    private func updateMenuBarIcon(memoryUsage: (free: Double, active: Double, inactive: Double, wired: Double, compressed: Double)) {
        guard let button = self.statusItem.button else {
            DDLogError("Could not retrieve the button of the 'MemoryUsageMenuBarItem'")
            return
        }

        let totalUsage = memoryUsage.active + memoryUsage.compressed + memoryUsage.wired

        // get all the necessary settings
        let graphColor = AppDelegate.userSettings.settings.memory.usageGraphColor.nsColor
        let gradientColor: NSColor? = AppDelegate.userSettings.settings.memory.colorGradientSettings.useGradient ? AppDelegate.userSettings.settings.memory.colorGradientSettings.secondaryColor.nsColor : nil
        let drawBorder = AppDelegate.userSettings.settings.memory.showUsageGraphBorder

        if AppDelegate.userSettings.settings.memory.usageGraphKind == .bar {
            button.image = self.barGraph.getImage(currentValue: Double(totalUsage), graphColor: graphColor, drawBorder: drawBorder, gradientColor: gradientColor)
        } else {
            button.image = self.lineGraph.getImage(currentValue: Double(totalUsage), graphColor: graphColor, drawBorder: drawBorder, gradientColor: gradientColor)
        }

        // add the value to the line graph history
        // this allows us to draw the resent history when the user switches to the line graph
        self.lineGraph.addValue(value: Double(totalUsage))
    }
}