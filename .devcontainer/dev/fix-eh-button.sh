#!/bin/sh
# EH Button Fix Helper
# Diagnose and fix non-working button issues (Event Handler/Error Handler/Emergency Help)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_success() { echo "${GREEN}✓${NC} $1"; }
print_error() { echo "${RED}✗${NC} $1"; }
print_info() { echo "${YELLOW}ℹ${NC} $1"; }
print_action() { echo "${CYAN}→${NC} $1"; }
print_header() { echo "\n${BLUE}═══${NC} $1 ${BLUE}═══${NC}"; }

# Scan for EH button references
scan_eh_button() {
    print_header "Scanning for EH Button References"
    
    local found=0
    
    # Search in HTML files
    print_info "Searching HTML files..."
    find . -name "*.html" -type f 2>/dev/null | while read -r file; do
        if grep -qi "eh.*button\|EH.*btn\|emergency.*help\|event.*handler.*btn" "$file" 2>/dev/null; then
            print_success "Found in: $file"
            grep -ni "eh.*button\|EH.*btn\|emergency.*help\|event.*handler.*btn" "$file" | head -10
            found=1
        fi
    done
    
    # Search in JavaScript files
    print_info "Searching JavaScript files..."
    find . -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" 2>/dev/null | while read -r file; do
        if grep -qi "eh.*button\|EH.*btn\|emergency.*help\|eventHandler" "$file" 2>/dev/null; then
            print_success "Found in: $file"
            grep -ni "eh.*button\|EH.*btn\|emergency.*help\|eventHandler" "$file" | head -10
            found=1
        fi
    done
    
    # Search in CSS files
    print_info "Searching CSS files..."
    find . -name "*.css" -o -name "*.scss" -o -name "*.less" 2>/dev/null | while read -r file; do
        if grep -qi "eh-button\|eh-btn\|\.eh\b" "$file" 2>/dev/null; then
            print_success "Found in: $file"
            grep -ni "eh-button\|eh-btn\|\.eh\b" "$file" | head -5
            found=1
        fi
    done
    
    if [ "$found" -eq 0 ]; then
        print_error "No EH button references found in project"
        print_info "Please provide more details about your EH button:"
        echo "  1. What does EH stand for?"
        echo "  2. Where is the button located?"
        echo "  3. What should it do when clicked?"
    fi
}

# Diagnose common button issues
diagnose_button() {
    print_header "Button Diagnostics"
    
    local button_id="${1:-eh-button}"
    
    # Check 1: Is the button in HTML?
    print_info "Checking if button exists in DOM..."
    if grep -rq "id=\"$button_id\"\|id='$button_id'\|\"$button_id\"" --include="*.html" --include="*.js" --include="*.jsx" --include="*.tsx" --include="*.vue" . 2>/dev/null; then
        print_success "Button element found in code"
    else
        print_error "Button element '$button_id' not found in code"
        print_action "Create a button with id='$button_id'"
    fi
    
    # Check 2: Is there an event listener attached?
    print_info "Checking for event listeners..."
    if grep -rq "addEventListener.*$button_id\|onclick.*$button_id\|\.on('click'.*$button_id\|@click.*$button_id" --include="*.js" --include="*.jsx" --include="*.ts" --include="*.tsx" --include="*.vue" . 2>/dev/null; then
        print_success "Event listener found"
    else
        print_error "No event listener found for '$button_id'"
        print_action "Common ways to add click handler:"
        echo "  - JavaScript: document.getElementById('$button_id').addEventListener('click', handler)"
        echo "  - HTML: <button onclick='handler()'>"
        echo "  - Vue: <button @click='handler'>"
        echo "  - React: <button onClick={handler}>"
    fi
    
    # Check 3: Console errors?
    print_info "Common JavaScript errors to check in browser console:"
    echo "  - 'Cannot read property of null' → Button doesn't exist when script runs"
    echo "  - 'handler is not defined' → Function name is wrong or not in scope"
    echo "  - 'Cannot read property of undefined' → Event object issue"
    
    # Check 4: CSS issues
    print_info "Checking CSS for button visibility..."
    if grep -rq "display:\s*none\|visibility:\s*hidden\|opacity:\s*0\|pointer-events:\s*none" --include="*.css" --include="*.scss" . 2>/dev/null; then
        print_error "Button might be hidden by CSS"
    fi
}

# Fix common button issues
fix_button() {
    print_header "Applying Button Fixes"
    
    # Create backup
    backup_dir="eh_button_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    print_success "Backups will be saved in: $backup_dir"
    
    # Fix 1: Add event listener wrapper to ensure DOM is loaded
    print_action "Checking for DOM-ready wrapper..."
    find . -name "*.js" -type f 2>/dev/null | while read -r file; do
        if grep -q "addEventListener\|\.on(" "$file" 2>/dev/null && ! grep -q "DOMContentLoaded\|\.ready\|document.*ready" "$file" 2>/dev/null; then
            cp "$file" "$backup_dir/$(basename "$file")"
            print_info "Adding DOM-ready wrapper to $file"
            
            # This is a simple example - actual fix depends on your code structure
            cat >> "$file" << 'EOF'

// Auto-added fix: Ensure DOM is loaded before attaching events
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initEHButton);
} else {
    initEHButton();
}
EOF
            print_success "Added DOM-ready wrapper"
        fi
    done
    
    # Fix 2: Check for duplicate IDs
    print_action "Checking for duplicate button IDs..."
    find . -name "*.html" -type f 2>/dev/null | while read -r file; do
        dupes=$(grep -o 'id="[^"]*"' "$file" | sort | uniq -d)
        if [ -n "$dupes" ]; then
            print_error "Duplicate IDs found in $file:"
            echo "$dupes"
        fi
    done
}

# Create a test EH button setup
create_test_button() {
    print_header "Creating Test EH Button"
    
    cat > eh-button-test.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EH Button Test</title>
    <style>
        .eh-button {
            padding: 12px 24px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            margin: 10px;
        }
        .eh-button:hover {
            background-color: #0056b3;
        }
        .eh-button:active {
            transform: scale(0.98);
        }
        .eh-button.disabled {
            background-color: #6c757d;
            cursor: not-allowed;
            pointer-events: none;
        }
        #eh-status {
            margin: 10px;
            padding: 10px;
            border-radius: 4px;
        }
    </style>
</head>
<body>
    <h1>EH Button Test Page</h1>
    
    <!-- Test Button -->
    <button id="eh-button" class="eh-button">Click Me (EH Button)</button>
    
    <!-- Status Display -->
    <div id="eh-status"></div>
    
    <!-- Debug Info -->
    <pre id="debug-info"></pre>

    <script>
        // Wait for DOM to be ready
        function initEHButton() {
            const button = document.getElementById('eh-button');
            const status = document.getElementById('eh-status');
            const debug = document.getElementById('debug-info');
            
            // Debug: Show if button was found
            debug.innerHTML = 'Debug Info:\n';
            debug.innerHTML += 'Button found: ' + (button ? '✅ Yes' : '❌ No') + '\n';
            debug.innerHTML += 'Button disabled: ' + (button?.disabled ? 'Yes' : 'No') + '\n';
            debug.innerHTML += 'Button visible: ' + (button?.offsetParent !== null ? '✅ Yes' : '❌ No (hidden)') + '\n';
            debug.innerHTML += 'Has click handler: Pending test...\n';
            
            if (!button) {
                status.innerHTML = '❌ Error: Button not found!';
                status.style.color = 'red';
                console.error('EH Button not found in DOM');
                return;
            }
            
            // Attach click handler
            button.addEventListener('click', function(event) {
                console.log('✅ EH Button clicked!', event);
                
                status.innerHTML = '✅ EH Button works! Clicked at: ' + new Date().toLocaleTimeString();
                status.style.backgroundColor = '#d4edda';
                status.style.color = '#155724';
                
                // Your EH button logic here
                alert('EH Button is working correctly!');
            });
            
            // Also add keyboard support
            button.addEventListener('keydown', function(event) {
                if (event.key === 'Enter' || event.key === ' ') {
                    event.preventDefault();
                    button.click();
                }
            });
            
            debug.innerHTML += 'Has click handler: ✅ Yes\n';
            status.innerHTML = '✅ EH Button ready! Click to test.';
            status.style.backgroundColor = '#fff3cd';
            status.style.color = '#856404';
            
            console.log('EH Button initialized successfully');
        }
        
        // Initialize when DOM is ready
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', initEHButton);
        } else {
            initEHButton();
        }
    </script>
</body>
</html>
EOF
    
    print_success "Created eh-button-test.html"
    print_action "Open this file in your browser to test:"
    echo "  file://$(pwd)/eh-button-test.html"
    echo "  Or serve it: python3 -m http.server 8000"
}

# Generate debug code for existing button
generate_debug() {
    print_header "Generating Debug Code"
    
    cat << 'EOF'
    
Add this debug code near your EH button JavaScript:

```javascript
// EH Button Debug
(function() {
    console.log('🔍 EH Button Debug Starting...');
    
    // Replace 'eh-button' with your actual button ID
    const buttonId = 'eh-button'; // <-- CHANGE THIS
    const button = document.getElementById(buttonId);
    
    console.log('1. Button element:', button);
    console.log('2. Button exists:', !!button);
    
    if (button) {
        console.log('3. Button disabled:', button.disabled);
        console.log('4. Button visible:', button.offsetParent !== null);
        console.log('5. Button style.display:', window.getComputedStyle(button).display);
        console.log('6. Button z-index:', window.getComputedStyle(button).zIndex);
        console.log('7. Button pointer-events:', window.getComputedStyle(button).pointerEvents);
        
        // Check if any parent is hidden
        let parent = button.parentElement;
        while (parent) {
            const style = window.getComputedStyle(parent);
            if (style.display === 'none') {
                console.log('❌ Parent hidden:', parent);
            }
            parent = parent.parentElement;
        }
        
        // Monitor clicks
        button.addEventListener('click', function(e) {
            console.log('✅ Button clicked!', e);
            alert('Button is working!');
        }, { once: true });
        
        console.log('✅ Click handler attached');
    } else {
        console.error('❌ Button not found! Available buttons:');
        console.log(document.querySelectorAll('button'));
    }
})();
```

EOF
}

Main menu

main() {
case "${1:-help}" in
"scan")
scan_eh_button
;;
"diagnose")
diagnose_button "${2:-eh-button}"
;;
"fix")
diagnose_button "${2:-eh-button}"
fix_button
;;
"test")
create_test_button
;;
"debug")
generate_debug
;;
"all")
scan_eh_button
echo ""
diagnose_button "${2:-eh-button}"
echo ""
fix_button
echo ""
generate_debug
;;
"help"|*)
echo "EH Button Fix Helper"
echo ""
echo "Commands:"
echo "  scan              - Find EH button references in project"
echo "  diagnose [id]     - Diagnose specific button (default: eh-button)"
echo "  fix [id]          - Apply fixes for button issues"
echo "  test              - Create test EH button page"
echo "  debug             - Generate debug JavaScript code"
echo "  all [id]          - Run everything (scan + diagnose + fix + debug)"
echo "  help              - Show this help"
echo ""
echo "Common causes for non-working buttons:"
echo "  1. Button doesn't exist in DOM yet (script runs before HTML loads)"
echo "  2. Wrong button ID or selector"
echo "  3. Event listener not attached"
echo "  4. Button is hidden by CSS (display:none/visibility:hidden)"
echo "  5. Button is disabled (disabled attribute)"
echo "  6. JavaScript error before event listener is attached"
echo "  7. Event propagation stopped by parent elements"
echo "  8. z-index issue - button behind another element"
echo ""
echo "Quick test - Create and open test page:"
echo "  ./dev/fix-eh-button.sh test"
echo "  open eh-button-test.html"
;;
esac
}

main "$@"

```

## Make it executable:

```bash
chmod +x dev/fix-eh-button.sh
```

Usage based on your specific situation:

If you want to find where the EH button is defined:

```bash
./dev/fix-eh-button.sh scan
```

If you know the button ID:

```bash
./dev/fix-eh-button.sh diagnose your-button-id
```

To create a working test page:

```bash
./dev/fix-eh-button.sh test
```

To generate debug code to add to your page:

```bash
./dev/fix-eh-button.sh debug
```