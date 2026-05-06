        const API_KEY = "AIzaSyB3Br7KLVZKNk-Eosk9_csZ7U4rH81H-z0"; 
        let genAI, model;
        
        if (API_KEY && API_KEY !== "PLACEHOLDER_API_KEY") {
            genAI = new GoogleGenerativeAI(API_KEY);
            model = genAI.getGenerativeModel({ 
                model: "gemini-1.5-flash",
                systemInstruction: "You are the Ethic Hawks Forensic Assistant. Expertise: The Wilbur Method™, SA Companies Act, PFMA. Tone: Clinical, authoritative, precise."
            });
        }
