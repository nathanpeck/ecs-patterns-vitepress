<script setup>
import { ref, onMounted } from 'vue'

const externalLink = ref(null)

onMounted(() => {
  externalLink.value.addEventListener("click", function (e) {
    window.location.assign(externalLink.value.getAttribute('href'));
    e.stopPropagation();
    return true;
  });
})
</script>

<template>
  <div class="sell-wrapper">
    <div class="selling-point">
      <h2>Are you ready to <b>build</b> with containers on AWS?</h2>

      <p>
        Containers are great for your application. And AWS is great for containers.
      </p>
      <ul>
        <li>Over <b>2.25 billion</b> Amazon Elastic Container Service tasks are launched every week</li>
        <li><b>65%</b> of all new AWS containers customers use Amazon ECS, driving <b>tens of thousands</b> of API calls
          per second</li>
        <li>Largest single account production workload on Amazon ECS: <b>5.48 million</b> concurrent vCPUs</li>
        <li>Fastest task placement rate for a single Amazon ECS cluster: <b>750 tasks/sec</b></li>
      </ul>
      <a class='btn' href="https://aws.amazon.com/ecs/">
        Learn more about Amazon ECS
      </a>
    </div>
    <div class="selling-point">
      <img class='featured-img' src="/featured-pattern.svg" />
      <h2><b>Patterns</b> Collection</h2>

      <p>
        Building from scratch is hard.
      </p>
      <p>Bring your ideas to life with production ready patterns:
      </p>
      <ul>
        <li>Example snippets across AWS CloudFormation, AWS Cloud Development Kit, Terraform,
          and Pulumi</li>
        <li>Bash scripts for deployments and administrative tasks</li>
        <li>Sample task definitions and Dockerfiles</li>
      </ul>
      <a class="btn" href="/pattern">
        Patterns
      </a>
    </div>
    <div class="selling-point">
      <img class='featured-img' style="width: 35%;" src="/cftc.webp" />
      <h2>Get the Latest <b>Updates</b></h2>

      <p>
        There's always more to learn.
      </p>
      <p>
        Keep up with the latest announcements
        and news in the world of containers on AWS.
      </p>
      <button class="btn" ref='externalLink' href="https://d2rkbl8jpwujc2.cloudfront.net/blog/">
        Blog
      </button>
      <a class="btn" href="https://www.youtube.com/@ContainersfromtheCouch">
        Containers From the Couch <i class="fab fa-youtube social-icon" aria-hidden="true"></i>
      </a>
    </div>
  </div>
</template>

<style scoped>
.sell-wrapper {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  background-color: var(--warm-content-bg);
  padding-top: 40px;
}

.selling-point {
  flex-grow: 1;
  flex-basis: align-items;
  border: 1px solid var(--bs-border-color-translucent);
  border-radius: 5px;
  background-color: var(--bs-tertiary-bg);
  padding: 40px;
  width: 100%;
  max-width: 1000px;
  margin: 0 auto;
  margin-bottom: 40px;
}

.selling-point h2 {
  padding-bottom: 10px;
  color: var(--bs-emphasis-color)
}

.featured-img {
  width: 50%;
  float: right;
  border: 3px solid rgb(var(--custom-highlight-color));
  margin-left: 30px;
}

.selling-point .btn {
  font-weight: bold;
  background-color: rgb(var(--custom-highlight-color));
  color: white;
  padding: 5px;
  padding-left: 10px;
  padding-right: 10px;
  font-size: 1.1em;
  border-radius: 5px;
  margin-right: 10px;
  margin-top: 15px;
}
</style>
