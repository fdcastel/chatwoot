<script setup>
import Icon from 'dashboard/components-next/icon/Icon.vue';

defineProps({
  displayName: { type: String, default: 'SSO' },
  iconUrl: { type: String, default: '' },
});

function initiateOidcLogin() {
  window.location.href = '/auth/openid_connect';
}
</script>

<template>
  <div class="flex flex-col">
    <button
      class="inline-flex justify-center w-full px-4 py-3 bg-n-background dark:bg-n-solid-3 items-center rounded-md shadow-sm ring-1 ring-inset ring-n-container dark:ring-n-container focus:outline-offset-0 hover:bg-n-alpha-2 dark:hover:bg-n-alpha-2"
      @click="initiateOidcLogin"
    >
      <img v-if="iconUrl" :src="iconUrl" class="h-5 w-5" alt="" />
      <Icon
        v-else
        icon="i-lucide-lock-keyhole"
        class="size-5 text-n-slate-11"
      />
      <span class="ml-2 text-base font-medium text-n-slate-12">
        {{ $t('LOGIN.OIDC.BUTTON', { provider: displayName }) }}
      </span>
    </button>
  </div>
</template>
