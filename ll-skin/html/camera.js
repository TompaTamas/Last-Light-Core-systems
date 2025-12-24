// Last Light Skin - Camera Control (NUI side)

let isDragging = false;
let lastMouseX = 0;
let currentRotation = 0;

// Mouse down event (start dragging)
document.addEventListener('mousedown', (e) => {
    // Only allow dragging in the main content area (not on buttons/inputs)
    if (e.target.closest('.content') && !e.target.closest('button, input, select')) {
        isDragging = true;
        lastMouseX = e.clientX;
        document.body.style.cursor = 'grabbing';
    }
});

// Mouse up event (stop dragging)
document.addEventListener('mouseup', () => {
    isDragging = false;
    document.body.style.cursor = 'default';
});

// Mouse move event (rotate character)
document.addEventListener('mousemove', (e) => {
    if (!isDragging) return;
    
    const deltaX = e.clientX - lastMouseX;
    lastMouseX = e.clientX;
    
    // Calculate rotation based on mouse movement
    const rotationSpeed = 0.5; // Adjust for sensitivity
    const rotation = deltaX * rotationSpeed;
    
    currentRotation += rotation;
    
    // Send rotation to Lua
    sendRotation(currentRotation);
});

// Send rotation update to Lua
function sendRotation(rotation) {
    fetch(`https://${GetParentResourceName()}/rotateCamera`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({rotation: rotation})
    });
}

// Touch support for mobile
let lastTouchX = 0;

document.addEventListener('touchstart', (e) => {
    if (e.target.closest('.content') && !e.target.closest('button, input, select')) {
        lastTouchX = e.touches[0].clientX;
    }
});

document.addEventListener('touchmove', (e) => {
    if (!e.target.closest('.content')) return;
    
    const touch = e.touches[0];
    const deltaX = touch.clientX - lastTouchX;
    lastTouchX = touch.clientX;
    
    const rotationSpeed = 0.3;
    const rotation = deltaX * rotationSpeed;
    
    currentRotation += rotation;
    sendRotation(currentRotation);
    
    e.preventDefault();
});

// Reset rotation when changing camera position
window.addEventListener('message', (event) => {
    const data = event.data;
    
    if (data.action === 'resetRotation') {
        currentRotation = 0;
    }
});

// Mouse wheel zoom (optional)
document.addEventListener('wheel', (e) => {
    if (!document.getElementById('app').classList.contains('hidden')) {
        const zoomDelta = e.deltaY > 0 ? 0.1 : -0.1;
        
        fetch(`https://${GetParentResourceName()}/zoomCamera`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({zoom: zoomDelta})
        });
        
        e.preventDefault();
    }
});

// Get parent resource name
function GetParentResourceName() {
    return 'll-skin';
}

// Export functions
window.CameraControl = {
    resetRotation: function() {
        currentRotation = 0;
    },
    
    setRotation: function(rotation) {
        currentRotation = rotation;
    },
    
    getRotation: function() {
        return currentRotation;
    }
};