#!/bin/bash

# Script to help identify which Swift files need to be added to Xcode project

echo "Swift files in Shared folder:"
echo "============================"
find Shared -name "*.swift" | sort

echo -e "\nFiles currently in the Xcode project:"
echo "====================================="
grep -o "Shared/.*\.swift" PanoramaApp.xcodeproj/project.pbxproj | sort | uniq

echo -e "\nTo add these files to Xcode:"
echo "1. Open PanoramaApp.xcodeproj in Xcode"
echo "2. Right-click the 'Shared' group"
echo "3. Select 'Add Files to PanoramaApp...'"
echo "4. Select these files:"
echo "   - TextFieldViewlet.swift"
echo "   - FormExampleViewlet.swift"
echo "   - NoteCardViewlet.swift"
echo "5. Make sure both iOS and macOS targets are selected"
echo "6. Click 'Add'"