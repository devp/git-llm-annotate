document.addEventListener('DOMContentLoaded', () => {
    const swiperWrapper = document.querySelector('.swiper-wrapper');

    fetch('data/feed.json')
        .then(response => response.json())
        .then(data => {
            data.items.forEach(item => {
                const slide = document.createElement('div');
                slide.classList.add('swiper-slide');

                let content = `
                    <div class="card">
                        <div class="card-content">
                            <h2>${item.title}</h2>
                            <p>${item.description}</p>
                        </div>
                    </div>
                `;

                if (item.imageUrl) {
                    slide.style.backgroundImage = `url(${item.imageUrl})`;
                } else if (item.thumbnailUrl) {
                    slide.style.backgroundImage = `url(${item.thumbnailUrl})`;
                    slide.dataset.videoUrl = item.videoUrl;
                    const playButton = document.createElement('div');
                    playButton.classList.add('play-button');
                    playButton.innerHTML = '▶';
                    slide.appendChild(playButton);
                }

                slide.innerHTML += content;
                swiperWrapper.appendChild(slide);

                if (item.videoUrl) {
                    slide.addEventListener('click', () => {
                        window.open(item.videoUrl, '_blank');
                    });
                }
            });

            new Swiper('.swiper-container', {
                direction: 'vertical',
                loop: false,
                pagination: {
                    el: '.swiper-pagination',
                    clickable: true,
                },
                navigation: {
                    nextEl: '.swiper-button-next',
                    prevEl: '.swiper-button-prev',
                },
            });
        });

    if ('serviceWorker' in navigator) {
        window.addEventListener('load', () => {
            navigator.serviceWorker.register('sw.js').then(registration => {
                console.log('ServiceWorker registration successful with scope: ', registration.scope);
            }, err => {
                console.log('ServiceWorker registration failed: ', err);
            });
        });
    }
});