import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from '../ui/components/column';
import {
  refreshTimeline,
  updateTimeline,
  deleteFromTimelines,
  connectTimeline,
  disconnectTimeline,
} from '../../actions/timelines';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ColumnBackButtonSlim from '../../components/column_back_button_slim';
import createStream from '../../stream';

const messages = defineMessages({
  title: { id: 'column.union', defaultMessage: 'Union timeline' },
});

const mapStateToProps = state => ({
  hasUnread: state.getIn(['timelines', 'union', 'unread']) > 0,
  streamingAPIBaseURL: state.getIn(['meta', 'streaming_api_base_url']),
  accessToken: state.getIn(['meta', 'access_token']),
});

let subscription;

class UnionTimeline extends React.PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    streamingAPIBaseURL: PropTypes.string.isRequired,
    accessToken: PropTypes.string.isRequired,
    hasUnread: PropTypes.bool,
  };

  componentDidMount () {
    const { dispatch, streamingAPIBaseURL, accessToken } = this.props;

    dispatch(refreshTimeline('union'));

    if (typeof subscription !== 'undefined') {
      return;
    }

    subscription = createStream(streamingAPIBaseURL, accessToken, 'public:union', {

      connected () {
        dispatch(connectTimeline('union'));
      },

      reconnected () {
        dispatch(connectTimeline('union'));
      },

      disconnected () {
        dispatch(disconnectTimeline('union'));
      },

      received (data) {
        switch(data.event) {
        case 'update':
          dispatch(updateTimeline('union', JSON.parse(data.payload)));
          break;
        case 'delete':
          dispatch(deleteFromTimelines(data.payload));
          break;
        }
      },

    });
  }

  componentWillUnmount () {
    // if (typeof subscription !== 'undefined') {
    //   subscription.close();
    //   subscription = null;
    // }
  }

  render () {
    const { intl, hasUnread } = this.props;

    return (
      <Column icon='product-hunt' active={hasUnread} heading={intl.formatMessage(messages.title)}>
        <ColumnBackButtonSlim />
        <StatusListContainer {...this.props} scrollKey='union_timeline' type='union' emptyMessage={<FormattedMessage id='empty_column.union' defaultMessage='The union timeline is empty. Write something publicly to get the ball rolling!' />} />
      </Column>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(UnionTimeline));
