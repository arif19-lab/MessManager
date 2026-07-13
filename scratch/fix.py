import sys

file_path = r'C:\Users\Imran\mess_manager\lib\screens\home_screen.dart'
try:
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    for i, line in enumerate(lines):
        if 'Widget _buildSettingsDropdown' in line:
            print(f"Dropdown starts at {i}")
        if '_triggerThemeTransition' in line:
            print(f"TriggerTheme starts at {i}")
        if '_showSettingsPanel' in line:
            print(f"ShowSettings starts at {i}")
        if '_buildSettingsPanelContent' in line:
            print(f"SettingsPanelContent starts at {i}")
except Exception as e:
    print(e)
