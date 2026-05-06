#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   ⚖️  Ethic Hawks Button Fixer      ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
echo ""

# Show current location
echo -e "${YELLOW}📍 Current location:${NC} $(pwd)"
echo ""

# Check for HTML files
echo -e "${YELLOW}🔍 Looking for HTML files...${NC}"
html_files=$(find . -maxdepth 2 -name "*.html" -type f 2>/dev/null)
if [ -n "$html_files" ]; then
    echo -e "${GREEN}Found HTML files:${NC}"
    echo "$html_files"
else
    echo -e "${RED}No HTML files found in current directory${NC}"
fi
echo ""

# Check for JavaScript files
echo -e "${YELLOW}🔍 Looking for JavaScript files...${NC}"
js_files=$(find . -maxdepth 2 -name "*.js" -type f 2>/dev/null)
if [ -n "$js_files" ]; then
    echo -e "${GREEN}Found JS files:${NC}"
    echo "$js_files"
else
    echo -e "${RED}No JS files found in current directory${NC}"
fi
echo ""

# Check for button references
echo -e "${YELLOW}🔍 Searching for EH button references...${NC}"
grep -r "eh-button\|eh_button\|ethic.hawks\|EH.button" --include="*.html" --include="*.js" . 2>/dev/null || echo -e "${RED}No EH button references found${NC}"
echo ""

# Create test HTML if none exists
if [ -z "$html_files" ]; then
    echo -e "${YELLOW}📝 Creating test EH button page...${NC}"
    cat > eh-button-test.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>EH Button Test</title>
</head>
<body>
    <h1>Ethic Hawks Button Test</h1>
    <button id="eh-button" onclick="alert('EH Button Works!')">Click Me</button>
    <script>
        document.getElementById('eh-button').addEventListener('click', function() {
            console.log('EH Button clicked!');
        });
    </script>
</body>
</html>
EOF
    echo -e "${GREEN}✅ Created eh-button-test.html${NC}"
fi

echo -e "${YELLOW}💡 Quick Tips:${NC}"
echo "  1. Open your HTML file in a browser"
echo "  2. Press F12 → Console tab"
echo "  3. Look for red error messages"
echo "  4. Check if button ID matches in HTML and JavaScript"
echo ""
echo -e "${GREEN}✅ Diagnostic complete!${NC}"
