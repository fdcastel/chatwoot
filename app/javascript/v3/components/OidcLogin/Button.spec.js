import { shallowMount } from '@vue/test-utils';
import OidcLoginButton from './Button.vue';

function getWrapper(props = {}) {
  return shallowMount(OidcLoginButton, {
    props,
    mocks: { $t: (key, params) => `${key} ${JSON.stringify(params)}` },
  });
}

describe('OidcLoginButton.vue', () => {
  it('renders with default display name', () => {
    const wrapper = getWrapper();
    expect(wrapper.text()).toContain('SSO');
  });

  it('renders with custom display name', () => {
    const wrapper = getWrapper({ displayName: 'Authentik' });
    expect(wrapper.text()).toContain('Authentik');
  });

  it('renders icon when iconUrl is provided', () => {
    const wrapper = getWrapper({ iconUrl: 'https://example.com/icon.png' });
    const img = wrapper.find('img');
    expect(img.exists()).toBe(true);
    expect(img.attributes('src')).toBe('https://example.com/icon.png');
  });

  it('does not render img when iconUrl is empty', () => {
    const wrapper = getWrapper({ iconUrl: '' });
    expect(wrapper.find('img').exists()).toBe(false);
  });

  it('redirects to OIDC auth endpoint on click', () => {
    delete window.location;
    window.location = { href: '' };

    const wrapper = getWrapper();
    wrapper.find('button').trigger('click');
    expect(window.location.href).toBe('/auth/openid_connect');
  });
});
