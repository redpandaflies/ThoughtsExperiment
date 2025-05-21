//
//  GoalsPickerView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 5/20/25.
//

import SwiftUI

struct GoalsPickerView: View {
    @Binding var selectedSegment: GoalsPicker
    
    init(selectedSegment: Binding<GoalsPicker>) {
        
        self._selectedSegment = selectedSegment
        
        // 1) Create a medium‐weight system font
        let selectedFont = UIFont.systemFont(ofSize: 13, weight: .medium)
        let unselectedFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        // 2) Add the “condensed” trait to its descriptor
        guard let condensedDescriptorSelected = selectedFont.fontDescriptor
            .withSymbolicTraits(.traitCondensed) else {
            fatalError("Couldn’t make condensed font descriptor")
        }
        
        guard let condensedDescriptorUnselected = unselectedFont.fontDescriptor
            .withSymbolicTraits(.traitCondensed) else {
            fatalError("Couldn’t make condensed font descriptor")
        }
        
        // 3) Build final font from that descriptor
        let condensedMediumSelected = UIFont(descriptor: condensedDescriptorSelected, size: 13)
        let condensedMediumUnselected = UIFont(descriptor: condensedDescriptorUnselected, size: 13)
        
        // 4) Apply it in your appearance proxy
        UISegmentedControl.appearance().setTitleTextAttributes([
            .font: condensedMediumSelected,
            .foregroundColor: UIColor.black
        ], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([
            .font: condensedMediumUnselected,
            .foregroundColor: UIColor.black
        ], for: .normal)
        
        //change color
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.white.withAlphaComponent(0.4)
        UISegmentedControl.appearance().backgroundColor = AppColors.pickerColorPrimaryUI.withAlphaComponent(0.6)
    }
    
    var body: some View {
        Picker("", selection: $selectedSegment) {
            ForEach(GoalsPicker.allCases, id: \.self) { segment in
                Text(segment.pickerHeading())
            }
        }
        .pickerStyle(.segmented)
        .tint(AppColors.pickerColorSelected)
        .blendMode(.plusLighter)
        .frame(width: 170)
    }
}

