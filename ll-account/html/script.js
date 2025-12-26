// Last Light Account System - NUI Script

let currentCharacters = [];
let selectedCharacter = null;
let config = {};

// Message listener
window.addEventListener('message', (event) => {
    const data = event.data;
    
    switch(data.action) {
        case 'setVisible':
            setVisible(data.visible);
            break;
        case 'setConfig':
            config = data.config;
            break;
        case 'loadCharacters':
            loadCharacters(data.characters);
            break;
        case 'showLogin':
            showLogin();
            break;
        case 'openCreator':
            openBasicCreator(data.config);
            break;
        case 'showSpawnSelector':
            showSpawnSelector(data);
            break;
        case 'fadeOut':
            fadeOut();
            break;
        case 'hideUI':
            hideUI();
            break;
        case 'hideCreator':
            hideCreator();
            break;
    }
});

// Visibility
function setVisible(visible) {
    if (visible) {
        document.body.style.display = 'block';
        document.getElementById('app').classList.remove('hidden');
    } else {
        document.getElementById('app').classList.add('hidden');
    }
}

function hideUI() {
    document.body.style.display = 'none';
}

function fadeOut() {
    document.getElementById('app').style.opacity = '0';
    setTimeout(() => {
        hideUI();
    }, 1000);
}

// Show login screen
function showLogin() {
    document.getElementById('character-selection').classList.add('hidden');
    document.getElementById('character-creator').classList.add('hidden');
    document.getElementById('spawn-selector').classList.add('hidden');
}

// Load characters
function loadCharacters(characters) {
    currentCharacters = characters;
    
    document.getElementById('character-selection').classList.remove('hidden');
    document.getElementById('character-creator').classList.add('hidden');
    
    const grid = document.getElementById('characters-grid');
    grid.innerHTML = '';
    
    // Karakterek megjelenítése
    characters.forEach(char => {
        const card = createCharacterCard(char);
        grid.appendChild(card);
    });
    
    // Új karakter gomb (ha van hely)
    if (characters.length < config.maxCharacters) {
        const newCard = createNewCharacterCard();
        grid.appendChild(newCard);
    }
}

// Create character card
function createCharacterCard(character) {
    const card = document.createElement('div');
    card.className = 'character-card';
    card.innerHTML = `
        <div class="character-preview">
            <div class="character-model">
                <span class="character-icon">${character.sex === 'm' ? '👨' : '👩'}</span>
            </div>
        </div>
        <div class="character-info">
            <h3 class="character-name">${character.firstname} ${character.lastname}</h3>
            <div class="character-details">
                <span class="detail-item">📅 ${formatDate(character.dateofbirth)}</span>
                <span class="detail-item">📏 ${character.height} cm</span>
            </div>
            <div class="character-stats">
                <span class="stat-item">Last played: ${formatLastLogin(character.last_login)}</span>
            </div>
        </div>
        <div class="character-actions">
            <button class="btn btn-primary character-play-btn" data-charid="${character.id}">
                Play
            </button>
            ${config.enableDelete ? `
            <button class="btn btn-danger character-delete-btn" data-charid="${character.id}">
                Delete
            </button>
            ` : ''}
        </div>
    `;
    
    // Event listeners
    card.querySelector('.character-play-btn').addEventListener('click', () => {
        selectCharacter(character.id);
    });
    
    if (config.enableDelete) {
        card.querySelector('.character-delete-btn').addEventListener('click', () => {
            deleteCharacter(character.id);
        });
    }
    
    return card;
}

// Create new character card
function createNewCharacterCard() {
    const card = document.createElement('div');
    card.className = 'character-card new-character-card';
    card.innerHTML = `
        <div class="new-character-content">
            <div class="new-character-icon">➕</div>
            <h3>Create New Character</h3>
        </div>
    `;
    
    // Click handler a teljes kártyán
    card.addEventListener('click', () => {
        showCharacterCreator();
    });
    
    return card;
}

// Select character
function selectCharacter(charid) {
    fetch(`https://${GetParentResourceName()}/selectCharacter`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ charid: charid })
    });
}

// Delete character
function deleteCharacter(charid) {
    if (confirm('Are you sure you want to delete this character? This action cannot be undone!')) {
        fetch(`https://${GetParentResourceName()}/deleteCharacter`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ charid: charid })
        });
    }
}

// Show character creator
function showCharacterCreator() {
    document.getElementById('character-selection').classList.add('hidden');
    document.getElementById('character-creator').classList.remove('hidden');
}

// Open creator (with config) - BASIC CREATOR (before spawn)
function openBasicCreator(creatorConfig) {
    document.getElementById('character-creator').classList.remove('hidden');
    
    // Setup date picker
    setupDatePicker(creatorConfig);
    
    // Setup height slider
    setupHeightSlider(creatorConfig);
}

// Setup date picker
function setupDatePicker(creatorConfig) {
    const dobInput = document.getElementById('dateofbirth');
    
    if (dobInput) {
        // Set max date (minAge years ago)
        const maxDate = new Date();
        maxDate.setFullYear(maxDate.getFullYear() - (creatorConfig.minAge || 18));
        
        // Set min date (maxAge years ago)
        const minDate = new Date();
        minDate.setFullYear(minDate.getFullYear() - (creatorConfig.maxAge || 80));
        
        dobInput.max = maxDate.toISOString().split('T')[0];
        dobInput.min = minDate.toISOString().split('T')[0];
    }
}

// Setup height slider
function setupHeightSlider(creatorConfig) {
    const heightSlider = document.getElementById('height');
    const heightValue = document.getElementById('height-value');
    
    if (heightSlider && heightValue) {
        heightSlider.min = creatorConfig.minHeight || 150;
        heightSlider.max = creatorConfig.maxHeight || 220;
        heightSlider.value = 175;
        heightValue.textContent = '175 cm';
        
        heightSlider.addEventListener('input', () => {
            heightValue.textContent = heightSlider.value + ' cm';
        });
    }
}

// Create character form submit
const characterForm = document.getElementById('character-creator-form');
if (characterForm) {
    characterForm.addEventListener('submit', (e) => {
        e.preventDefault();
        
        const formData = {
            firstname: document.getElementById('firstname').value,
            lastname: document.getElementById('lastname').value,
            dateofbirth: document.getElementById('dateofbirth').value,
            gender: document.querySelector('input[name="gender"]:checked')?.value || 'm',
            height: parseInt(document.getElementById('height').value)
        };
        
        // Validation
        if (!formData.firstname || !formData.lastname || !formData.dateofbirth) {
            alert('Please fill in all fields!');
            return;
        }
        
        // Send to Lua
        fetch(`https://${GetParentResourceName()}/createCharacter`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(formData)
        }).then(resp => resp.json()).then(data => {
            if (!data.success) {
                alert(data.error || 'Failed to create character');
            }
            // Ha sikeres, a spawn selector fog megnyílni
        });
    });
}

// Back to character selection
const backBtn = document.getElementById('back-to-selection-btn');
if (backBtn) {
    backBtn.addEventListener('click', () => {
        document.getElementById('character-creator').classList.add('hidden');
        document.getElementById('character-selection').classList.remove('hidden');
    });
}

// Spawn selector
function showSpawnSelector(data) {
    console.log('Showing spawn selector', data);
    
    document.getElementById('character-creator').classList.add('hidden');
    document.getElementById('character-selection').classList.add('hidden');
    document.getElementById('spawn-selector').classList.remove('hidden');
    
    const spawnGrid = document.getElementById('spawn-grid');
    if (!spawnGrid) {
        console.error('spawn-grid not found!');
        return;
    }
    
    spawnGrid.innerHTML = '';
    
    data.spawns.forEach((spawn, index) => {
        const card = document.createElement('div');
        card.className = 'spawn-card';
        card.innerHTML = `
            <div class="spawn-image" style="background-image: url('assets/${spawn.image}')"></div>
            <div class="spawn-info">
                <h3 class="spawn-name">${spawn.label}</h3>
            </div>
        `;
        
        spawnGrid.appendChild(card);
        
        // Click handler a teljes card-on
        card.addEventListener('click', () => {
            console.log('Spawn selected - index:', index);
            
            // Visual feedback
            document.querySelectorAll('.spawn-card').forEach(c => c.classList.remove('selected'));
            card.classList.add('selected');
            
            // Send to Lua
            fetch(`https://${GetParentResourceName()}/confirmSpawn`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ spawnIndex: index })
            }).then(resp => resp.json()).then(result => {
                if (result.success) {
                    console.log('Spawn confirmed successfully');
                } else {
                    console.error('Spawn confirm failed:', result.error);
                    alert(result.error || 'Failed to confirm spawn');
                }
            }).catch(err => {
                console.error('Fetch error:', err);
            });
        });
    });
}

// Utility functions
function formatDate(dateStr) {
    if (!dateStr) return 'N/A';
    const date = new Date(dateStr);
    return date.toLocaleDateString();
}

function formatLastLogin(dateStr) {
    if (!dateStr) return 'Never';
    const date = new Date(dateStr);
    const now = new Date();
    const diff = now - date;
    
    const minutes = Math.floor(diff / 60000);
    const hours = Math.floor(diff / 3600000);
    const days = Math.floor(diff / 86400000);
    
    if (minutes < 60) return `${minutes} minutes ago`;
    if (hours < 24) return `${hours} hours ago`;
    return `${days} days ago`;
}

function GetParentResourceName() {
    return 'll-account';
}

// ESC key handling
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }
});

// ========================================
// POST-SPAWN CHARACTER CREATOR
// ========================================

function hideCreator() {
    document.getElementById('character-creator-advanced')?.classList.add('hidden');
}

// Setup creator tabs
function setupCreatorTabs() {
    document.querySelectorAll('.creator-tab').forEach(tab => {
        tab.addEventListener('click', () => {
            const tabName = tab.getAttribute('data-tab');
            
            // Update active tab
            document.querySelectorAll('.creator-tab').forEach(t => t.classList.remove('active'));
            tab.classList.add('active');
            
            // Show content
            document.querySelectorAll('.creator-content').forEach(c => c.classList.remove('active'));
            document.getElementById(`creator-${tabName}`)?.classList.add('active');
        });
    });
}

// Setup heritage sliders
function setupCreatorHeritage() {
    const sliders = ['heritage-mom', 'heritage-dad', 'heritage-similarity', 'heritage-skin-similarity'];
    
    sliders.forEach(id => {
        const slider = document.getElementById(id);
        if (!slider) return;
        
        slider.addEventListener('input', () => {
            const mom = parseInt(document.getElementById('heritage-mom').value);
            const dad = parseInt(document.getElementById('heritage-dad').value);
            const similarity = parseInt(document.getElementById('heritage-similarity').value) / 100;
            const skinSim = parseInt(document.getElementById('heritage-skin-similarity').value) / 100;
            
            // Update displays
            document.getElementById('heritage-mom-value').textContent = mom;
            document.getElementById('heritage-dad-value').textContent = dad;
            document.getElementById('heritage-similarity-value').textContent = Math.round(similarity * 100) + '%';
            document.getElementById('heritage-skin-value').textContent = Math.round(skinSim * 100) + '%';
            
            // Send to Lua
            fetch(`https://${GetParentResourceName()}/updateCreatorHeritage`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    mom: mom,
                    dad: dad,
                    similarity: similarity,
                    skin_similarity: skinSim
                })
            });
        });
    });
}

// Setup face features
function setupCreatorFaceFeatures() {
    const features = [
        'nose_width', 'nose_peak_height', 'nose_peak_length', 'nose_bone_height',
        'eyebrows_height', 'eyebrows_width', 'cheekbone_height', 'cheekbone_width',
        'cheeks_width', 'eyes_opening', 'lips_thickness', 'jaw_bone_width',
        'jaw_bone_back_length', 'chin_bone_lowering', 'chin_bone_length',
        'chin_bone_width', 'chin_hole', 'neck_thickness'
    ];
    
    const container = document.getElementById('face-features-container');
    if (!container) return;
    
    container.innerHTML = '';
    
    features.forEach(feature => {
        const label = feature.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
        
        const div = document.createElement('div');
        div.className = 'creator-slider-group';
        div.innerHTML = `
            <label class="creator-label">${label}</label>
            <div class="slider-with-value">
                <input type="range" class="creator-slider" id="face-${feature}" 
                       min="-100" max="100" value="0">
                <span class="slider-value" id="face-${feature}-value">0</span>
            </div>
        `;
        
        container.appendChild(div);
        
        const slider = div.querySelector('input');
        slider.addEventListener('input', () => {
            const value = parseInt(slider.value) / 100;
            div.querySelector('.slider-value').textContent = slider.value;
            
            fetch(`https://${GetParentResourceName()}/updateCreatorFaceFeature`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    feature: feature,
                    value: value
                })
            });
        });
    });
}

// Setup hair controls
function setupCreatorHair() {
    const sliders = ['hair-style', 'hair-color', 'hair-highlight'];
    
    sliders.forEach(id => {
        const slider = document.getElementById(id);
        if (!slider) return;
        
        slider.addEventListener('input', () => {
            const style = parseInt(document.getElementById('hair-style').value);
            const color = parseInt(document.getElementById('hair-color').value);
            const highlight = parseInt(document.getElementById('hair-highlight').value);
            
            // Update displays
            document.getElementById('hair-style-value').textContent = style;
            document.getElementById('hair-color-value').textContent = color;
            document.getElementById('hair-highlight-value').textContent = highlight;
            
            // Send to Lua
            fetch(`https://${GetParentResourceName()}/updateCreatorHair`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    style: style,
                    color: color,
                    highlight: highlight
                })
            });
        });
    });
}

// Setup features (eyebrows, beard, etc)
function setupCreatorFeatures() {
    const overlays = [
        {name: 'eyebrows', hasColor: true, hasOpacity: true},
        {name: 'beard', hasColor: true, hasOpacity: true},
        {name: 'eye', hasColor: true, hasOpacity: false}
    ];
    
    overlays.forEach(overlay => {
        const styleSlider = document.getElementById(`${overlay.name}-style`);
        const colorSlider = document.getElementById(`${overlay.name}-color`);
        const opacitySlider = document.getElementById(`${overlay.name}-opacity`);
        
        if (styleSlider) {
            styleSlider.addEventListener('input', () => {
                const style = parseInt(styleSlider.value);
                const color = colorSlider ? parseInt(colorSlider.value) : 0;
                const opacity = opacitySlider ? parseInt(opacitySlider.value) / 100 : 1.0;
                
                document.getElementById(`${overlay.name}-style-value`).textContent = 
                    style === -1 ? 'None' : style;
                
                if (overlay.name === 'eye') {
                    // Eye color
                    fetch(`https://${GetParentResourceName()}/updateCreatorEyeColor`, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ color: style })
                    });
                } else {
                    // Other overlays
                    fetch(`https://${GetParentResourceName()}/updateCreatorOverlay`, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            overlay: overlay.name,
                            style: style,
                            color: color,
                            opacity: opacity
                        })
                    });
                }
            });
        }
        
        if (colorSlider) {
            colorSlider.addEventListener('input', () => {
                const style = parseInt(styleSlider.value);
                const color = parseInt(colorSlider.value);
                const opacity = opacitySlider ? parseInt(opacitySlider.value) / 100 : 1.0;
                
                document.getElementById(`${overlay.name}-color-value`).textContent = color;
                
                fetch(`https://${GetParentResourceName()}/updateCreatorOverlay`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        overlay: overlay.name,
                        style: style,
                        color: color,
                        opacity: opacity
                    })
                });
            });
        }
        
        if (opacitySlider) {
            opacitySlider.addEventListener('input', () => {
                const style = parseInt(styleSlider.value);
                const color = colorSlider ? parseInt(colorSlider.value) : 0;
                const opacity = parseInt(opacitySlider.value) / 100;
                
                document.getElementById(`${overlay.name}-opacity-value`).textContent = 
                    Math.round(opacity * 100) + '%';
                
                fetch(`https://${GetParentResourceName()}/updateCreatorOverlay`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        overlay: overlay.name,
                        style: style,
                        color: color,
                        opacity: opacity
                    })
                });
            });
        }
    });
}

// Setup camera buttons
function setupCreatorCamera() {
    document.querySelectorAll('.creator-camera-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            const position = btn.getAttribute('data-camera');
            
            document.querySelectorAll('.creator-camera-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            
            fetch(`https://${GetParentResourceName()}/changeCreatorCamera`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ position: position })
            });
        });
    });
}

// Initialize creator when opened
document.addEventListener('DOMContentLoaded', () => {
    console.log('ll-account NUI loaded');
    
    // Setup creator controls when creator opens
    window.addEventListener('message', (event) => {
        if (event.data.action === 'openCreator' && event.data.skinData) {
            console.log('Setting up post-spawn creator...');
            
            const creatorDiv = document.getElementById('character-creator-advanced');
            if (creatorDiv) {
                creatorDiv.classList.remove('hidden');
                
                // Setup all controls
                setTimeout(() => {
                    setupCreatorTabs();
                    setupCreatorHeritage();
                    setupCreatorFaceFeatures();
                    setupCreatorHair();
                    setupCreatorFeatures();
                    setupCreatorCamera();
                    console.log('Creator controls initialized');
                }, 100);
            }
        }
    });
});

// Finish button
document.getElementById('finish-creator-btn')?.addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/finishCreator`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

// Cancel button
document.getElementById('cancel-creator-btn')?.addEventListener('click', () => {
    if (confirm('Are you sure? Your changes will be lost.')) {
        fetch(`https://${GetParentResourceName()}/cancelCreator`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }
});

// Reset button
document.getElementById('reset-creator-btn')?.addEventListener('click', () => {
    if (confirm('Reset all changes to default?')) {
        fetch(`https://${GetParentResourceName()}/resetCreator`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }
});