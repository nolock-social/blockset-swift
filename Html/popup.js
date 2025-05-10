document.addEventListener("DOMContentLoaded", function () {
  const img = document.querySelector(".clickable-img");
  const popup = document.querySelector(".image-popup");
  const popupImg = document.getElementById("popup-img");
  const closeBtn = document.querySelector(".close-popup");
  const body = document.body;

  // Функция для блокировки скролла
  function disableScroll() {
    body.style.overflow = "hidden";
    body.style.position = "fixed";
    body.style.width = "100%";
  }

  function enableScroll() {
    body.style.overflow = "";
    body.style.position = "";
    body.style.width = "";
  }

  // Открытие попапа
  img.addEventListener("click", function () {
    popup.style.display = "block";
    popupImg.src = this.src;
    disableScroll();
  });

  // Закрытие попапа
  function closePopup() {
    popup.style.display = "none";
    enableScroll();
  }

  closeBtn.addEventListener("click", closePopup);
  popup.addEventListener("click", function (e) {
    if (e.target === this) closePopup();
  });

  document.addEventListener("keydown", function (e) {
    if (e.key === "Escape" && popup.style.display === "block") closePopup();
  });
});
