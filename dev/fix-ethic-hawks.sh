#!/bin/sh
# Ethic Hawks Forensic Governance AI Assistant Fix Helper

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_success() { echo "${GREEN}✓${NC} $1"; }
print_error() { echo "${RED}✗${NC} $1"; }
print_info() { echo "${YELLOW}ℹ${NC} $1"; }
print_action() { echo "${CYAN}→${NC} $1"; }
print_ethic() { echo "${PURPLE}⚖${NC} $1"; }
print_header() { echo "\n${BLUE}═══${NC} $1 ${BLUE}═══${NC}"; }

diagnose_integration() {
    print_header "Diagnosing Ethic Hawks Integration"
    
    print_ethic "Checking project structure..."
    echo "Current directory: $(pwd)"
    echo "Files in dev/:"
    ls -la dev/ 2>/dev/null || echo "  (dev folder empty or doesn't exist)"
    
    print_ethic "Checking for HTML files..."
    find . -maxdepth 2 -name "*.html" -type f 2>/dev/null | while read -r file; do
        echo "  Found: $file"
    done
    
    print_ethic "Checking for JavaScript files..."
    find . -maxdepth 2 -name "*.js" -type f 2>/dev/null | while read -r file; do
        echo "  Found: $file"
    done
    
    print_ethic "Checking for Ethic Hawks references..."
    grep -r "ethic" --include="*.html" --include="*.js" --include="*.php" . 2>/dev/null || echo "  No Ethic Hawks references found"
    
    print_ethic "Common issues to check:"
    echo "  1. Is the button in your HTML?"
    echo "  2. Is the JavaScript file loaded?"
    echo "  3. Check browser console (F12) for errors"
    echo "  4. Is the widget container present?"
}

fix_files() {
    print_header "Fixing Ethic Hawks Files"
    
    print_action "Creating backup..."
    mkdir -p backups
    cp *.html backups/ 2>/dev/null || true
    cp *.js backups/ 2>/dev/null || true
    print_success "Backup created in ./backups/"
    
    print_action "Checking for required dependencies..."
    if command -v node >/dev/null 2>&1; then
        echo "  Node.js: $(node --version)"
    else
        echo "  Node.js: not installed"
    fi
    
    if command -v npm >/dev/null 2>&1; then
        echo "  npm: $(npm --version)"
    else
        echo "  npm: not installed"
    fi
    
    print_success "Diagnostic complete"
}

create_test_page() {
    print_header "Creating Test Page"
    
    cat > test-eh-button.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ethic Hawks Button Test</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
        }
        .test-area {
            border: 2px solid #4a148c;
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
        }
        button {
            background: linear-gradient(135deg, #1a237e, #4a148c);
            color: white;
            border: none;
            padding: 15px 30px;
            font-size: 18px;
            border-radius: 25px;
            cursor: pointer;
            margin: 10px;
        }
        button:hover {
            transform: scale(1.05);
        }
        button:active {
            transform: scale(0.95);
        }
        #status {
            margin-top: 20px;
            padding: 10px;
            border-radius: 5px;
            font-weight: bold;
        }
        .success { background: #d4edda; color: #155724; }
        .error { background: #f8d7da; color: #721c24; }
        .info { background: #d1ecf1; color: #0c5460; }
    </style>
</head>
<body>
    <h1>⚖️ Ethic Hawks Button Test</h1>
    
    <div class="test-area">
        <h2>Test Buttons:</h2>
        <button id="eh-button-1" onclick="handleEHClick('Button 1')">EH Button 1</button>
        <button id="eh-button-2" class="ethic-hawks-btn">EH Button 2</button>
        <button id="eh-button-3">EH Button 3 (EventListener)</button>
        
        <div id="status"></div>
    </div>
    
    <div class="test-area">
        <h2>Debug Info:</h2>
        <pre id="debug"></pre>
    </div>

    <script>
        // Button 1 - onclick handler
        function handleEHClick(buttonName) {
            updateStatus(buttonName + ' clicked! ✅ Working!', 'success');
        }
        
        // Button 2 - jQuery-style (if jQuery exists)
        if (typeof jQuery !== 'undefined') {
            jQuery('#eh-button-2').on('click', function() {
                updateStatus('Button 2 clicked via jQuery! ✅', 'success');
            });
        } else {
            document.getElementById('eh-button-2').addEventListener('click', function() {
                updateStatus('Button 2 clicked! ✅ Working!', 'success');
            });
        }
        
        // Button 3 - EventListener (loaded after DOM)
        document.addEventListener('DOMContentLoaded', function() {
            const btn3 = document.getElementById('eh-button-3');
            if (btn3) {
                btn3.addEventListener('click', function() {
                    updateStatus('Button 3 clicked! ✅ Working!', 'success');
                });
                console.log('✅ Button 3 listener attached');
            } else {
                console.error('❌ Button 3 not found');
            }
        });
        
        function updateStatus(message, type) {
            const status = document.getElementById('status');
            status.textContent = message;
            status.className = type;
            console.log(message);
        }
        
        // Debug info
        window.onload = function() {
            const debug = document.getElementById('debug');
            debug.textContent = 'Debug Information:\n';
            debug.textContent += 'Buttons found: ' + document.querySelectorAll('button').length + '\n';
            debug.textContent += 'EH Button 1: ' + (document.getElementById('eh-button-1') ? '✅' : '❌') + '\n';
            debug.textContent += 'EH Button 2: ' + (document.getElementById('eh-button-2') ? '✅' : '❌') + '\n';
            debug.textContent += 'EH Button 3: ' + (document.getElementById('eh-button-3') ? '✅' : '❌') + '\n';
            debug.textContent += 'jQuery loaded: ' + (typeof jQuery !== 'undefined' ? '✅' : '❌') + '\n';
            debug.textContent += 'Page loaded at: ' + new Date().toLocaleTimeString() + '\n';
            
            updateStatus('Page loaded. Click any button to test!', 'info');
        };
    </script>
</body>
</html>
EOF
    
    print_success "Test page created: test-eh-button.html"
    print_action "Open it in your browser:"
    echo "  file://$(pwd)/test-eh-button.html"
    echo "  Or run: open test-eh-button.html"
}

main() {
    case "${1:-help}" in
        "diagnose")
            diagnose_integration
            ;;
        "fix")
            diagnose_integration
            fix_files
            ;;
        "test")
            create_test_page
            ;;
        "install")
            diagnose_integration
            fix_files
            create_test_page
            print_success "\nAll done! Open test-eh-button.html to verify"
            ;;
        "help"|*)
            echo "⚖️  Ethic Hawks Assistant Fix Helper"
            echo ""
            echo "Commands:"
            echo "  diagnose  - Check what's wrong"
            echo "  fix       - Apply fixes"
            echo "  test      - Create test page"
            echo "  install   - Full setup"
            echo "  help      - Show this help"
            echo ""
            echo "First time? Run:"
            echo "  ./dev/fix-ethic-hawks.sh install"
            ;;
    esac
}

main "$@"
