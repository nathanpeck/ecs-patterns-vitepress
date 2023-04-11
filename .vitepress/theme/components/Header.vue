<script setup>
import DarkModeSwitch from './DarkModeSwitch.vue';
import { ref, onMounted, onUnmounted } from 'vue';

const header = ref(null);
let checkHeaderInterval = null;

onMounted(() => {
  let scrolled = false;
  let lastObservedY = 0;

  document.addEventListener("scroll", (event) => {
    scrolled = true;
  })

  checkHeaderInterval = setInterval(function () {
    if (!scrolled) {
      return;
    }

    adjustHeader()
    scrolled = false;
  }, 250);

  function adjustHeader() {
    const thisObservedY = window.scrollY;

    if (thisObservedY < 100) {
      // Don't start hiding the header until scrolled far enough
      // down the page.
      header.value.classList.remove('nav-shown');
      header.value.classList.remove('nav-hidden');
      return;
    }

    if (lastObservedY < thisObservedY) {
      // Scrolling down so hide the header
      header.value.classList.add('nav-hidden');
      header.value.classList.remove('nav-shown');
      console.log('hiding header');
    } else {
      // Scrolling up so show the header
      header.value.classList.add('nav-shown');
      header.value.classList.remove('nav-hidden');
      console.log('showing header');
    }

    lastObservedY = thisObservedY;

    /*var n = e(this).scrollTop();
    if (Math.abs(t - n) <= o)
      return;
    n > t && n > i ? (e("nav").removeClass("nav-down").addClass("nav-up"),
      e(".nav-up").css("top", -e("nav").outerHeight() + "px")) : n + e(window).height() < e(document).height() && (e("nav").removeClass("nav-up").addClass("nav-down"),
        e(".nav-up, .nav-down").css("top", "0px")),
      t = n*/
  }
})

onUnmounted(() => {
  clearInterval(checkHeaderInterval)
})

</script>

<template>
  <div class="header" ref="header">
    <a href="/">
      <span class="brand-test">
        <img src="/ship.svg" alt="Brand logo" />Containers on AWS
      </span>
    </a>
    <div class="headerLinks">
      <a href="https://main--prismatic-babka-239bef.netlify.app/">Blog</a>
      <DarkModeSwitch />
    </div>
  </div>
  <div class="topHeaderPadding"></div>
</template>

<style scoped>
.header {
  z-index: 100;
  position: fixed;
  width: 100%;
  background-color: #f39f86;
  background-image: url(/header-smaller.webp);
  background-size: 600px;
  padding: 20px;
  border-bottom: 5px solid rgb(246, 106, 49);
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
}

/* This provides a bit of padding behind the collapsible header because
   it is in a fixed position on the page. */
.topHeaderPadding {
  background-color: var(--warm-content-bg);
  padding-bottom: 100px;
}

.header.nav-hidden {
  margin-top: -100%;
  transition: all 1s;
}

.header.nav-shown {
  margin-top: 0;
  transition: all .3s;
}

.header a {
  text-decoration: none;
}

.headerLinks {
  display: flex;
  flex-direction: row;
  align-items: center;
}

.headerLinks a {

  color: var(--bs-emphasis-color);
  margin-right: 20px;
}

.brand-test {
  display: flex;
  align-items: center;
}

.brand-test {
  color: var(--bs-emphasis-color);
  cursor: pointer;
  text-decoration: none;
  font-size: 2.1em;
  line-height: 54px;
  margin: 0px;
  padding: 0px;
  font-family: Arial, Helvetica, sans-serif;
}

.brand-test img {
  vertical-align: middle;
  margin-right: .2em;
  height: 54px;
}

/** Mini header for mobile */
@media screen and (max-width: 600px) {
  .header {
    width: 100%;
    padding: 5px;
    background: rgb(2, 0, 36);
    background-color: #f39f86;
    background-image: url(/header-smaller.webp);
    background-size: 200px;
    border-bottom: 3px solid rgb(246, 106, 49);
    font-size: 1em;
  }

  .brand-test {
    font-size: 1em;
    line-height: 20px;
  }

  .brand-test img {
    height: 34px;
  }

  .extraLinks {
    display: none;
  }

  .topHeaderPadding {
    padding-bottom: 40px;
  }
}
</style>