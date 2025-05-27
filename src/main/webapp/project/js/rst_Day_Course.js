document.addEventListener("DOMContentLoaded", () => {
  const wrapper = document.getElementById("sliderWrapper");
  const slides = document.querySelectorAll(".slide");
  const prev = document.getElementById("prevBtn");
  const next = document.getElementById("nextBtn");

  const visible = 3;
  const total = slides.length;
  let current = 0;

  if (total === 0) return;

  const slideWidth = slides[0].offsetWidth;
  const maxPage = Math.ceil(total / visible) - 1;

  // 화살표 숨김 처리
  if (total <= visible) {
    prev.style.display = "none";
    next.style.display = "none";
  }

  // 슬라이더 위치 업데이트
  function updateSlider() {
    const offset = slideWidth * visible * current;
    wrapper.style.transform = `translateX(-${offset}px)`;
  }

  // 이전 버튼
  prev.addEventListener("click", () => {
    if (current > 0) {
      current--;
      updateSlider();
    }
  });

  // 다음 버튼
  next.addEventListener("click", () => {
    if (current < maxPage) {
      current++;
      updateSlider();
    }
  });

  // 슬라이드 클릭 시 가게 정보 표시 및 활성화 처리
  slides.forEach((slide, idx) => {
    slide.addEventListener("click", () => {
      activateUpTo(idx);
    });
  });

  // 원형 스텝/가게정보/활성 슬라이드 갱신
  function activateUpTo(index) {
    const steps = document.querySelectorAll("#progressbar li");
    const lines = document.querySelectorAll(".step-line");
    const infos = document.querySelectorAll(".store-info-item");

    // 스텝 동기화
    steps.forEach((li, i) => {
      li.classList.toggle("active", i <= index);
    });

    lines.forEach((line, i) => {
      line.classList.toggle("active", i < index);
    });

    // 가게 정보 노출
    infos.forEach((info) => {
      info.style.display = parseInt(info.dataset.index) === index + 1 ? "block" : "none";
    });

    // 슬라이드 강조 표시
    slides.forEach((slide, i) => {
      slide.classList.toggle("active", i === index);
    });
  }

  // 초기 0번 활성화
  activateUpTo(0);
});
