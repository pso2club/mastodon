import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from '../../components/column';
import ColumnHeader from '../../components/column_header';
import {
  refreshUnionTimeline,
  expandUnionTimeline,
  updateTimeline,
  deleteFromTimelines,
  connectTimeline,
  disconnectTimeline,
} from '../../actions/timelines';
import { addColumn, removeColumn, moveColumn } from '../../actions/columns';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ColumnBackButtonSlim from '../../components/column_back_button_slim';
import ColumnSettingsContainer from './containers/column_settings_container';
import createStream from '../../stream';

const messages = defineMessages({
  title: { id: 'column.union', defaultMessage: 'PSO2 timeline' },
});

const mapStateToProps = state => ({
  hasUnread: state.getIn(['timelines', 'union', 'unread']) > 0,
  streamingAPIBaseURL: state.getIn(['meta', 'streaming_api_base_url']),
  accessToken: state.getIn(['meta', 'access_token']),
});

class UnionTimeline extends React.PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    columnId: PropTypes.string,
    intl: PropTypes.object.isRequired,
    streamingAPIBaseURL: PropTypes.string.isRequired,
    accessToken: PropTypes.string.isRequired,
    hasUnread: PropTypes.bool,
    multiColumn: PropTypes.bool,
  };

  handlePin = () => {
    const { columnId, dispatch } = this.props;

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('UNION', {}));
    }
  }

  handleMove = (dir) => {
    const { columnId, dispatch } = this.props;
    dispatch(moveColumn(columnId, dir));
  }

  handleHeaderClick = () => {
    this.column.scrollTop();
  }

  componentDidMount () {
    const { dispatch, streamingAPIBaseURL, accessToken } = this.props;

    dispatch(refreshUnionTimeline());

    if (typeof this._subscription !== 'undefined') {
      return;
    }

    this._subscription = createStream(streamingAPIBaseURL, accessToken, 'union', {

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
    if (typeof this._subscription !== 'undefined') {
      this._subscription.close();
      this._subscription = null;
    }
  }

  setRef = c => {
    this.column = c;
  }

  handleLoadMore = () => {
    this.props.dispatch(expandUnionTimeline());
  }

  render () {
    const { intl, hasUnread, columnId, multiColumn } = this.props;
    const pinned = !!columnId;

    return (
      <Column ref={this.setRef}>
        <ColumnHeader
          icon='product-hunt'
          active={hasUnread}
          title={intl.formatMessage(messages.title)}
          onPin={this.handlePin}
          onMove={this.handleMove}
          onClick={this.handleHeaderClick}
          pinned={pinned}
          multiColumn={multiColumn}
        >
          <ColumnSettingsContainer />
        </ColumnHeader>

        <StatusListContainer
          trackScroll={!pinned}
          scrollKey={`union_timeline-${columnId}`}
          timelineId='union'
          loadMore={this.handleLoadMore}
          emptyMessage={<FormattedMessage id='empty_column.union' defaultMessage='There is nothing here! Write something publicly, or manually follow users from other PSO2 instances to fill it up' />}
        />
      </Column>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(UnionTimeline));
