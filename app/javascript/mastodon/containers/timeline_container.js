import React, { Fragment } from 'react';
import ReactDOM from 'react-dom';
import { Provider } from 'react-redux';
import PropTypes from 'prop-types';
import configureStore from '../store/configureStore';
import { hydrateStore } from '../actions/store';
import { IntlProvider, addLocaleData } from 'react-intl';
import { getLocale } from '../locales';
import PublicTimeline from '../features/standalone/public_timeline';
import CommunityTimeline from '../features/standalone/community_timeline';
import HashtagTimeline from '../features/standalone/hashtag_timeline';
import ModalContainer from '../features/ui/containers/modal_container';
import initialState from '../initial_state';

const { localeData, messages } = getLocale();
addLocaleData(localeData);

const store = configureStore();

if (initialState) {
  store.dispatch(hydrateStore(initialState));
}

export default class TimelineContainer extends React.PureComponent {

  static propTypes = {
    locale: PropTypes.string.isRequired,
    hashtag: PropTypes.string,
    showPublicTimeline: PropTypes.bool.isRequired,
    showUnionTimeline: PropTypes.bool.isRequired,
  };

  static defaultProps = {
    showPublicTimeline: initialState.settings.known_fediverse,
    showUnionTimeline: initialState.settings.known_union,
  };

  render () {
    const { locale, hashtag, showPublicTimeline, showUnionTimeline } = this.props;

    let timeline;

    if (hashtag) {
      timeline = <HashtagTimeline hashtag={hashtag} />;
    } else if (showPublicTimeline) {
      timeline = <PublicTimeline />;
    } else if (showUnionTimeline) {
      timeline = <UnionTimeline />;
    } else {
      timeline = <CommunityTimeline />;
    }

    return (
      <IntlProvider locale={locale} messages={messages}>
        <Provider store={store}>
          <Fragment>
            {timeline}
            {ReactDOM.createPortal(
              <ModalContainer />,
              document.getElementById('modal-container'),
            )}
          </Fragment>
        </Provider>
      </IntlProvider>
    );
  }

}
