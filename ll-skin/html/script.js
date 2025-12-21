// Last Light Skin - NUI Script

let currentSkin = {};
let config = {};
let currentComponent = 11; // Jacket default
let currentProp = 0;

// Face features list
const faceFeatures = [
    {id: 'nose_width', label: 'Nose Width', min: -1, max: 1},
    {id: 'nose_peak_height', label: 'Nose Peak Height', min: -1, max: 1},
    {id: 'nose_peak_length', label: 'Nose Peak Length', min: -1, max: 1},
    {id: 'nose_bone_height', label: 'Nose Bone Height', min: -1, max: 1},
    {id: 'eyebrows_height', label: 'Eyebrows Height', min: -1, max: 1},
    {id: 'eyebrows_width', label: 'Eyebrows Width', min: -1, max: 1},
    {id: 'cheekbone_height', label: 'Cheekbone Height', min: -1, max: 1},
    {id: 'cheekbone_width', label: 'Cheekbone Width', min: -1, max: 1},
    {id: 'cheeks_width', label: 'Cheeks Width', min: -1, max: 1},
    {id: 'eyes_opening', label: 'Eyes Opening', min: -1, max: 1},
    {id: 'lips_thickness', label: 'Lips Thickness', min: -1, max: 1},
    {id: 'jaw_bone_width', label: 'Jaw Width', min: -1, max: 1},
    {id: 'jaw_bone_back_length', label: 'Jaw Length', min: -1, max: 1},
    {id: 'chin_bone_lowering', label: 'Chin Lowering', min: -1, max: 1},
    {id: 'chin_bone_length', label: 'Chin Length', min: -1, max: 1},
    {id: 'chin_bone_width', label: 'Chin Width', min: -1, max: 1},
    {id: 'chin_hole', label: 'Chin Hole', min: -1, max: 1},
    {id: 'neck_thickness', label: 'Neck Thickness', min: -1, max: 1}
];

// Message listener
window.addEventListener('message', (event) => {
    const data = event.data;
    
    switch(data.action) {
        case 'openMenu':
            openMenu(data.skin, data.config);
            break;
        case 'closeMenu':
            closeMenu();
            break;
        case 'updateSkin':
            currentSkin = data.skin;
            break;
    }
});

// Open menu
function openMenu(skin, cfg) {
    currentSkin = skin || {};
    config = cfg || {};
    
    document.getElementById('app').classList.remove('hidden');
    document.getElementById('price-value').textContent = config.price > 0 ? `$${config.price}` : 'FREE';
    
    initializeFaceFeatures();
    initializeHeritage();
    
    console.log('Menu opened', currentSkin);
}

// Close menu
function closeMenu() {
    document.getElementById('app').classList.add('hidden');
}

// Initialize face features sliders
function initializeFaceFeatures() {
    const grid = document.getElementById('face-features-grid');
    grid.innerHTML = '';
    
    faceFeatures.forEach(feature => {
        const value = currentSkin.face && currentSkin.face[feature.id] ? currentSkin.face[feature.id] : 0;
        
        const controlGroup = document.createElement('div');
        controlGroup.className = 'control-group';
        controlGroup.innerHTML = `
            <label class="control-label">${feature.label.toUpperCase()}</label>
            <div class="slider-container">
                <input type="range" class="slider" data-feature="${feature.id}" 
                       min="${feature.min * 100}" max="${feature.max * 100}" value="${value * 100}" step="1">
                <span class="slider-value">${Math.round(value * 100)}</span>
            </div>
        `;
        
        grid.appendChild(controlGroup);
        
        // Event listener
        const slider = controlGroup.querySelector('.slider');
        const valueSpan = controlGroup.querySelector('.slider-value');
        
        slider.addEventListener('input', (e) => {
            const val = parseInt(e.target.value) / 100;
            valueSpan.textContent = Math.round(val * 100);
            
            sendUpdate('updateFaceFeature', {
                feature: feature.id,
                value: val
            });
        });
    });
}

// Initialize heritage sliders
function initializeHeritage() {
    const mother = document.getElementById('heritage-mother');
    const father = document.getElementById('heritage-father');
    const similarity = document.getElementById('heritage-similarity');
    const skin = document.getElementById('heritage-skin');
    
    // Set initial values
    if (currentSkin.heritage) {
        mother.value = currentSkin.heritage.mom || 0;
        father.value = currentSkin.heritage.dad || 0;
        similarity.value = (currentSkin.heritage.similarity || 0.5) * 100;
        skin.value = (currentSkin.heritage.skin_similarity || 0.5) * 100;
        
        mother.nextElementSibling.textContent = mother.value;
        father.nextElementSibling.textContent = father.value;
        similarity.nextElementSibling.textContent = similarity.value + '%';
        skin.nextElementSibling.textContent = skin.value + '%';
    }
    
    // Event listeners
    [mother, father, similarity, skin].forEach(slider => {
        slider.addEventListener('input', updateHeritage);
    });
}

function updateHeritage() {
    const mother = document.getElementById('heritage-mother');
    const father = document.getElementById('heritage-father');
    const similarity = document.getElementById('heritage-similarity');
    const skin = document.getElementById('heritage-skin');
    
    mother.nextElementSibling.textContent = mother.value;
    father.nextElementSibling.textContent = father.value;
    similarity.nextElementSibling.textContent = similarity.value + '%';
    skin.nextElementSibling.textContent = skin.value + '%';
    
    sendUpdate('updateHeritage', {
        mom: parseInt(mother.value),
        dad: parseInt(father.value),
        similarity: parseInt(similarity.value) / 100,
        skin_similarity: parseInt(skin.value) / 100
    });
}

// Category switching
document.querySelectorAll('.category-item').forEach(item => {
    item.addEventListener('click', () => {
        const category = item.dataset.category;
        
        // Update active category
        document.querySelectorAll('.category-item').forEach(i => i.classList.remove('active'));
        item.classList.add('active');
        
        // Update active section
        document.querySelectorAll('.content-section').forEach(s => s.classList.remove('active'));
        document.getElementById(`section-${category}`).classList.add('active');
    });
});

// Camera buttons
document.querySelectorAll('.camera-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        const camera = btn.dataset.camera;
        
        document.querySelectorAll('.camera-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        
        sendUpdate('updateCamera', {position: camera});
    });
});

// Clothes tabs
document.querySelectorAll('.clothes-tabs .tab-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        currentComponent = parseInt(btn.dataset.component);
        
        document.querySelectorAll('.clothes-tabs .tab-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        
        updateClothesUI();
    });
});

function updateClothesUI() {
    const drawable = currentSkin.components && currentSkin.components[currentComponent] 
        ? currentSkin.components[currentComponent].drawable : 0;
    const texture = currentSkin.components && currentSkin.components[currentComponent]
        ? currentSkin.components[currentComponent].texture : 0;
    
    document.getElementById('clothes-drawable-value').textContent = drawable;
    document.getElementById('clothes-texture-value').textContent = texture;
}

// Clothes controls
document.getElementById('clothes-drawable-prev').addEventListener('click', () => {
    changeClothesDrawable(-1);
});

document.getElementById('clothes-drawable-next').addEventListener('click', () => {
    changeClothesDrawable(1);
});

document.getElementById('clothes-texture-prev').addEventListener('click', () => {
    changeClothesTexture(-1);
});

document.getElementById('clothes-texture-next').addEventListener('click', () => {
    changeClothesTexture(1);
});

function changeClothesDrawable(direction) {
    const current = currentSkin.components && currentSkin.components[currentComponent]
        ? currentSkin.components[currentComponent].drawable : 0;
    const newValue = Math.max(0, current + direction);
    
    document.getElementById('clothes-drawable-value').textContent = newValue;
    
    sendUpdate('updateComponent', {
        component: currentComponent,
        drawable: newValue,
        texture: 0
    });
}

function changeClothesTexture(direction) {
    const drawable = currentSkin.components && currentSkin.components[currentComponent]
        ? currentSkin.components[currentComponent].drawable : 0;
    const current = currentSkin.components && currentSkin.components[currentComponent]
        ? currentSkin.components[currentComponent].texture : 0;
    const newValue = Math.max(0, current + direction);
    
    document.getElementById('clothes-texture-value').textContent = newValue;
    
    sendUpdate('updateComponent', {
        component: currentComponent,
        drawable: drawable,
        texture: newValue
    });
}

// Footer buttons
document.getElementById('save-btn').addEventListener('click', () => {
    sendAction('save');
});

document.getElementById('close-btn').addEventListener('click', () => {
    sendAction('close');
});

document.getElementById('reset-btn').addEventListener('click', () => {
    if (confirm('Reset all changes?')) {
        sendAction('reset');
    }
});

// Send update to Lua
function sendUpdate(action, data) {
    fetch(`https://${GetParentResourceName()}/${action}`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(data)
    });
}

// Send action to Lua
function sendAction(action) {
    fetch(`https://${GetParentResourceName()}/${action}`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({})
    });
}

// Get parent resource name
function GetParentResourceName() {
    return 'll-skin';
}

// ESC key
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        sendAction('close');
    }
});