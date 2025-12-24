// ll-account NUI Script

let config = {
    maxCharacters: 3,
    enableDelete: true,
    locale: 'hu'
};

let characters = [];
let selectedCharacter = null;
let currentStep = 1;
let selectedGender = 'm';
let selectedSpawn = null;

// DOM Elements
const app = document.getElementById('app');
const characterSelection = document.getElementById('character-selection');
const characterCreator = document.getElementById('character-creator');
const charactersGrid = document.getElementById('characters-grid');
const deleteModal = document.getElementById('delete-modal');

// Buttons
const playBtn = document.getElementById('play-btn');
const deleteBtn = document.getElementById('delete-btn');
const createCharacterBtn = document.getElementById('create-character-btn');
const creatorClose = document.getElementById('creator-close');
const creatorBack = document.getElementById('creator-back');
const creatorNext = document.getElementById('creator-next');
const creatorFinish = document.getElementById('creator-finish');
const cancelDelete = document.getElementById('cancel-delete');
const confirmDelete = document.getElementById('confirm-delete');

// Steps
const stepBasic = document.getElementById('step-basic');
const stepAppearance = document.getElementById('step-appearance');
const stepSpawn = document.getElementById('step-spawn');

// Current skin data
let currentSkin = {
    heritage: { mom: 0, dad: 0, similarity: 0.5, skin_similarity: 0.5 },
    components: {},
    props: {}
};

// Message Listener
window.addEventListener('message', (event) => {
    const data = event.data;
    
    switch(data.action) {
        case 'fadeOut':
            // Fade out animáció
            app.style.transition = 'opacity 1s ease-out';
            app.style.opacity = '0';
            console.log('UI fading out...');
            break;
        case 'hideUI':
            // TELJES UI elrejtése
            app.style.display = 'none';
            document.body.style.display = 'none';
            console.log('UI hidden - player spawned');
            break;
        case 'setVisible':
            setVisible(data.visible);
            break;
        case 'setConfig':
            setConfig(data.config);
            break;
        case 'loadCharacters':
            loadCharacters(data.characters);
            break;
        case 'openCreator':
            openCreator(data.config);
            break;
        case 'showSpawnSelector':
            showSpawnSelector(data.spawns);
            break;
    }
});

// Set Visibility
function setVisible(visible) {
    if (visible) {
        app.style.display = 'flex';
        app.style.opacity = '0';
        app.classList.remove('hidden');
        
        // Fade in
        setTimeout(() => {
            app.style.transition = 'opacity 0.5s ease-in';
            app.style.opacity = '1';
        }, 50);
        
        createParticles();
    } else {
        app.style.transition = 'opacity 0.5s ease-out';
        app.style.opacity = '0';
        
        setTimeout(() => {
            app.classList.add('hidden');
            app.style.display = 'none';
        }, 500);
    }
}

// Set Config
function setConfig(cfg) {
    config = { ...config, ...cfg };
    console.log('Config set:', config);
}

// Load Characters
function loadCharacters(chars) {
    characters = chars;
    charactersGrid.innerHTML = '';
    
    if (characters.length === 0) {
        charactersGrid.innerHTML = '<p style="text-align: center; color: #9ca3af;">Még nincs karaktered. Hozz létre egyet!</p>';
    }
    
    characters.forEach((char, index) => {
        const card = createCharacterCard(char, index);
        charactersGrid.appendChild(card);
    });
    
    // Show character selection
    characterSelection.classList.remove('hidden');
    characterCreator.classList.add('hidden');
    
    console.log('Loaded characters:', characters.length);
}

// Create Character Card
function createCharacterCard(char, index) {
    const card = document.createElement('div');
    card.className = 'character-card';
    card.dataset.charid = char.id;
    card.dataset.index = index;
    
    card.innerHTML = `
        <h3 class="character-name">${char.firstname} ${char.lastname}</h3>
        <div class="character-info">
            <div class="character-info-item">
                <span class="character-info-label">Nem:</span>
                <span>${char.sex === 'm' ? 'Férfi' : 'Nő'}</span>
            </div>
            <div class="character-info-item">
                <span class="character-info-label">Születési dátum:</span>
                <span>${char.dateofbirth}</span>
            </div>
            <div class="character-info-item">
                <span class="character-info-label">Magasság:</span>
                <span>${char.height} cm</span>
            </div>
            <div class="character-info-item">
                <span class="character-info-label">Utoljára:</span>
                <span>${formatDate(char.last_login)}</span>
            </div>
        </div>
    `;
    
    card.addEventListener('click', () => selectCharacter(char, card));
    
    return card;
}

// Select Character
function selectCharacter(char, card) {
    // Remove previous selection
    document.querySelectorAll('.character-card').forEach(c => {
        c.classList.remove('selected');
    });
    
    // Select new
    card.classList.add('selected');
    selectedCharacter = char;
    
    // Enable buttons
    playBtn.disabled = false;
    deleteBtn.disabled = !config.enableDelete;
    
    // Preview character (FiveM callback)
    fetch(`https://${GetParentResourceName()}/previewCharacter`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ charid: char.id })
    });
    
    console.log('Character selected:', char.firstname);
}

// Play Button
playBtn.addEventListener('click', () => {
    if (!selectedCharacter) return;
    
    console.log('Playing as:', selectedCharacter.firstname);
    
    fetch(`https://${GetParentResourceName()}/selectCharacter`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ charid: selectedCharacter.id })
    });
});

// Delete Button
deleteBtn.addEventListener('click', () => {
    if (!selectedCharacter) return;
    
    document.getElementById('delete-text').textContent = 
        `Biztosan törölni szeretnéd: ${selectedCharacter.firstname} ${selectedCharacter.lastname}?`;
    
    deleteModal.classList.remove('hidden');
});

// Cancel Delete
cancelDelete.addEventListener('click', () => {
    deleteModal.classList.add('hidden');
});

// Confirm Delete
confirmDelete.addEventListener('click', () => {
    if (!selectedCharacter) return;
    
    fetch(`https://${GetParentResourceName()}/deleteCharacter`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ charid: selectedCharacter.id })
    });
    
    deleteModal.classList.add('hidden');
    selectedCharacter = null;
    playBtn.disabled = true;
    deleteBtn.disabled = true;
});

// Create Character Button
createCharacterBtn.addEventListener('click', () => {
    if (characters.length >= config.maxCharacters) {
        alert('Elérted a maximum karakterek számát!');
        return;
    }
    
    console.log('Opening creator...');
    openCreator({});
});

// Open Creator
function openCreator(cfg) {
    console.log('Creator opened');
    
    characterSelection.classList.add('hidden');
    characterCreator.classList.remove('hidden');
    
    // Add preview hint if not exists
    if (!document.getElementById('preview-hint-overlay')) {
        const hint = document.createElement('div');
        hint.id = 'preview-hint-overlay';
        hint.style.cssText = `
            position: fixed;
            left: 10%;
            top: 50%;
            transform: translateY(-50%);
            background: rgba(0, 0, 0, 0.8);
            border: 2px dashed rgba(132, 204, 22, 0.5);
            border-radius: 10px;
            padding: 30px;
            text-align: center;
            pointer-events: none;
            z-index: 999;
        `;
        hint.innerHTML = `
            <h3 style="color: #84cc16; font-size: 28px; margin: 0 0 10px 0;">👤</h3>
            <p style="color: #9ca3af; margin: 0; font-size: 16px;">Karaktered előnézete</p>
            <p style="color: #6b7280; margin: 5px 0 0 0; font-size: 12px;">Használd az egeret a forgatáshoz</p>
        `;
        document.body.appendChild(hint);
    }
    
    // Reset form
    document.getElementById('firstname').value = '';
    document.getElementById('lastname').value = '';
    document.getElementById('dateofbirth').value = '';
    document.getElementById('height').value = '175';
    
    currentStep = 1;
    selectedGender = 'm';
    selectedSpawn = null;
    
    // Set active gender button
    document.querySelectorAll('.gender-btn').forEach(btn => {
        btn.classList.remove('active');
        if (btn.dataset.gender === 'm') {
            btn.classList.add('active');
        }
    });
    
    showStep(1);
    
    // Create ped preview
    fetch(`https://${GetParentResourceName()}/changeGender`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ gender: 'm' })
    });
}

// Creator Close
creatorClose.addEventListener('click', () => {
    console.log('Creator closed');
    characterCreator.classList.add('hidden');
    characterSelection.classList.remove('hidden');
    
    // Remove preview hint
    const hint = document.getElementById('preview-hint-overlay');
    if (hint) {
        hint.remove();
    }
    
    // Notify Lua
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

// Gender Selection
document.querySelectorAll('.gender-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        document.querySelectorAll('.gender-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        selectedGender = btn.dataset.gender;
        
        console.log('Gender selected:', selectedGender);
        
        // Update preview
        fetch(`https://${GetParentResourceName()}/changeGender`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ gender: selectedGender })
        });
    });
});

// Show Step
function showStep(step) {
    document.querySelectorAll('.creator-step').forEach(s => s.classList.remove('active'));
    
    if (step === 1) {
        stepBasic.classList.add('active');
        creatorBack.classList.add('hidden');
        creatorNext.classList.remove('hidden');
        creatorFinish.classList.add('hidden');
    } else if (step === 2) {
        stepAppearance.classList.add('active');
        creatorBack.classList.remove('hidden');
        creatorNext.classList.remove('hidden');
        creatorFinish.classList.add('hidden');
    } else if (step === 3) {
        stepSpawn.classList.add('active');
        creatorBack.classList.remove('hidden');
        creatorNext.classList.add('hidden');
        creatorFinish.classList.remove('hidden');
    }
    
    currentStep = step;
    console.log('Step:', currentStep);
}

// Creator Navigation
creatorBack.addEventListener('click', () => {
    if (currentStep > 1) {
        showStep(currentStep - 1);
    }
});

creatorNext.addEventListener('click', () => {
    if (currentStep === 1) {
        // Validate basic info
        const firstname = document.getElementById('firstname').value.trim();
        const lastname = document.getElementById('lastname').value.trim();
        const dateofbirth = document.getElementById('dateofbirth').value;
        const height = document.getElementById('height').value;
        
        if (!firstname || !lastname || !dateofbirth || !height) {
            alert('Minden mező kitöltése kötelező!');
            return;
        }
        
        console.log('Basic info validated, moving to appearance');
        showStep(2);
        
    } else if (currentStep === 2) {
        // Appearance done, move to spawn
        console.log('Appearance done, moving to spawn selection');
        
        // Request spawn selector from Lua
        fetch(`https://${GetParentResourceName()}/selectSpawn`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
        
        showStep(3);
    }
});

// Show Spawn Selector
function showSpawnSelector(spawns) {
    const spawnGrid = document.getElementById('spawn-grid');
    spawnGrid.innerHTML = '';
    
    console.log('Showing spawn selector with', spawns.length, 'spawns');
    
    spawns.forEach((spawn, index) => {
        const card = createSpawnCard(spawn, index);
        spawnGrid.appendChild(card);
    });
}

// Create Spawn Card
function createSpawnCard(spawn, index) {
    const card = document.createElement('div');
    card.className = 'spawn-card';
    card.dataset.index = index;
    
    card.innerHTML = `
        <img src="assets/${spawn.image || 'default.jpg'}" alt="${spawn.label}" class="spawn-image" onerror="this.src='assets/default.jpg'">
        <div class="spawn-overlay">
            <h4 class="spawn-name">${spawn.label}</h4>
        </div>
    `;
    
    card.addEventListener('click', () => selectSpawn(index, card));
    
    return card;
}

// Select Spawn
function selectSpawn(index, card) {
    document.querySelectorAll('.spawn-card').forEach(c => c.classList.remove('selected'));
    card.classList.add('selected');
    selectedSpawn = index;
    
    console.log('Spawn selected:', index);
}

// Finish Character Creation
creatorFinish.addEventListener('click', () => {
    if (selectedSpawn === null) {
        alert('Válassz egy spawn pontot!');
        return;
    }
    
    const data = {
        firstname: document.getElementById('firstname').value.trim(),
        lastname: document.getElementById('lastname').value.trim(),
        dateofbirth: document.getElementById('dateofbirth').value,
        height: document.getElementById('height').value,
        gender: selectedGender,
        spawnIndex: selectedSpawn,
        skin: JSON.stringify(currentSkin) // Skin data hozzáadása
    };
    
    console.log('Creating character:', data);
    
    // Confirm spawn ELŐSZÖR
    fetch(`https://${GetParentResourceName()}/confirmSpawn`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ spawnIndex: selectedSpawn })
    }).then(() => {
        // AZTÁN create character
        fetch(`https://${GetParentResourceName()}/createCharacter`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        }).then(response => response.json())
          .then(result => {
              if (!result.success) {
                  alert(result.error || 'Hiba történt a karakter létrehozásakor!');
              }
          });
    });
});

// Heritage sliders
document.getElementById('heritage-mother')?.addEventListener('input', (e) => {
    const value = parseInt(e.target.value);
    document.getElementById('mother-value').textContent = value;
    currentSkin.heritage.mom = value;
    
    fetch(`https://${GetParentResourceName()}/updateHeritage`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(currentSkin.heritage)
    });
});

document.getElementById('heritage-father')?.addEventListener('input', (e) => {
    const value = parseInt(e.target.value);
    document.getElementById('father-value').textContent = value;
    currentSkin.heritage.dad = value;
    
    fetch(`https://${GetParentResourceName()}/updateHeritage`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(currentSkin.heritage)
    });
});

document.getElementById('heritage-similarity')?.addEventListener('input', (e) => {
    const value = parseInt(e.target.value) / 100;
    document.getElementById('similarity-value').textContent = Math.round(value * 100) + '%';
    currentSkin.heritage.similarity = value;
    
    fetch(`https://${GetParentResourceName()}/updateHeritage`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(currentSkin.heritage)
    });
});

document.getElementById('heritage-skin')?.addEventListener('input', (e) => {
    const value = parseInt(e.target.value) / 100;
    document.getElementById('skin-value').textContent = Math.round(value * 100) + '%';
    currentSkin.heritage.skin_similarity = value;
    
    fetch(`https://${GetParentResourceName()}/updateHeritage`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(currentSkin.heritage)
    });
});

// Particles Effect
function createParticles() {
    const particles = document.getElementById('particles');
    if (!particles) return;
    
    particles.innerHTML = '';
    
    for (let i = 0; i < 50; i++) {
        const particle = document.createElement('div');
        particle.className = 'particle';
        particle.style.cssText = `
            position: absolute;
            width: 2px;
            height: 2px;
            background: rgba(132, 204, 22, 0.5);
            border-radius: 50%;
            left: ${Math.random() * 100}%;
            top: ${Math.random() * 100}%;
            animation: float ${5 + Math.random() * 10}s infinite ease-in-out;
            animation-delay: ${Math.random() * 5}s;
        `;
        particles.appendChild(particle);
    }
}

// Format Date
function formatDate(dateStr) {
    if (!dateStr) return 'Ismeretlen';
    
    const date = new Date(dateStr);
    const now = new Date();
    const diff = now - date;
    
    const minutes = Math.floor(diff / 60000);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);
    
    if (minutes < 60) return `${minutes} perce`;
    if (hours < 24) return `${hours} órája`;
    if (days < 7) return `${days} napja`;
    
    return date.toLocaleDateString('hu-HU');
}

// Get Parent Resource Name
function GetParentResourceName() {
    return 'll-account';
}

// ESC Key
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        if (!deleteModal.classList.contains('hidden')) {
            deleteModal.classList.add('hidden');
        }
    }
});

// CSS Animation for particles
const style = document.createElement('style');
style.textContent = `
    @keyframes float {
        0%, 100% { transform: translateY(0) translateX(0); }
        25% { transform: translateY(-20px) translateX(10px); }
        50% { transform: translateY(-40px) translateX(-10px); }
        75% { transform: translateY(-20px) translateX(10px); }
    }
`;
document.head.appendChild(style);