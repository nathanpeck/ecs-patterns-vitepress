<script setup>
import DarkModeSwitch from './DarkModeSwitch.vue';
import { ref, onMounted, onUnmounted } from 'vue';

const header = ref(null);
const collapseSection = ref(null);
let checkHeaderInterval = null;

// This client side code controls the fixed navbar automatically
// collapsing when you scroll down the page and then reappearing
// when you scroll back up.
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
    } else {
      // Scrolling up so show the header
      header.value.classList.add('nav-shown');
      header.value.classList.remove('nav-hidden');
    }

    lastObservedY = thisObservedY;
  }
})

onUnmounted(() => {
  clearInterval(checkHeaderInterval)
})

// Action when the hamburger button is clicked
function toggleCollapse() {
  collapseSection.value.classList.toggle('collapse')
}
</script>

<template>
  <nav class="navbar navbar-expand-md bg-light fixed-top" ref="header">
    <div class="container-fluid">
      <a class="navbar-brand" hijack="false" href="/">
        <img class="ecs-brand" width="175" height="70" src="https://ecsland.jldeen.dev/images/ecs-land.png" alt="brand">
      </a>
      <button class="navbar-toggler" type="button" @click="toggleCollapse" aria-controls="navbarTogglerDemo01"
        aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse flex-row justify-content-end" ref="collapseSection">
        <ul class="navbar-nav mb-lg-0">
          <li class="nav-item ">
            <a class="nav-link" hijack="false" href="/">Home</a>
          </li>
          <li class="nav-item ">
            <a class="nav-link" hijack="false" href="/search">Search</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" hijack="false" href="/blog">Blog</a>
          </li>
          <li class="nav-item ">
            <a class="nav-link" href="/pattern/">Patterns</a>
          </li>
          <li class="nav-item ">
            <a class="nav-link" hijack="false" href="/about">About</a>
          </li>
        </ul>
        <DarkModeSwitch />
      </div>
    </div>
  </nav>
  <div class="topHeaderPadding"></div>
</template>

<style scoped>
.navbar {
  background-color: #f39f86;
  background-image: url(https://ecsland.jldeen.dev/images/header-smaller.webp);
  background-size: 600px;
  border-bottom: 5px solid rgb(246, 106, 49);
}

.navbar-toggler {
  border: 1px solid rgba(0, 0, 0, 0.5);
}

.navbar-toggler:focus {
  box-shadow: 0 0 0 var(--bs-navbar-toggler-focus-width) rgba(0, 0, 0, 0.5);
}

.navbar-toggler-icon {
  background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' width='30' height='30' viewBox='0 0 30 30'%3e%3cpath stroke='rgba(0, 0, 0, 0.5)' stroke-linecap='round' stroke-miterlimit='10' stroke-width='2' d='M4 7h22M4 15h22M4 23h22'/%3e%3c/svg%3e");
}

.navbar-brand {
  color: black;
  line-height: 30px;
}

.navbar-nav {
  padding-right: 10px;
}

.nav-link {
  color: black;
}

.header {
  position: fixed;
  z-index: 100;
  width: 100%;
}

/* This provides a bit of padding behind the collapsible header because
   it is in a fixed position on the page. */
.topHeaderPadding {
  background-color: var(--warm-content-bg);
  padding-bottom: 100px;
}

.navbar.nav-hidden {
  margin-top: -100%;
  transition: all 1s;
}

.navbar.nav-shown {
  margin-top: 0;
  transition: all .3s;
}

.ecs-brand {
  border-radius: 80px;
  border: 3px solid #f66a31;
  margin-left: 2rem;
}
</style>