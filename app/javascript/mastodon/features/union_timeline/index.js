import React from 'react';
import { connect } from 'react-redux';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import PropTypes from 'prop-types';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from '../../components/column';
import ColumnHeader from '../../components/column_header';
import { expandUnionTimeline } from '../../actions/timelines';
import { addColumn, removeColumn, moveColumn, changeColumnParams } from '../../actions/columns';
import ColumnSettingsContainer from './containers/column_settings_container';
import SectionHeadline from '../community_timeline/components/section_headline';
import { connectUnionStream } from '../../actions/streaming';

const messages = defineMessages({
  title: { id: 'column.union', defaultMessage: 'Union timeline' },
});

const mapStateToProps = (state, { onlyMedia }) => ({
  hasUnread: state.getIn(['timelines', `union${onlyMedia ? ':media' : ''}`, 'unread']) > 0,
});

@connect(mapStateToProps)
@injectIntl
export default class UnionTimeline extends React.PureComponent {

  static defaultProps = {
    onlyMedia: false,
  };

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    columnId: PropTypes.string,
    intl: PropTypes.object.isRequired,
    hasUnread: PropTypes.bool,
    multiColumn: PropTypes.bool,
    onlyMedia: PropTypes.bool,
  };

  handlePin = () => {
    const { columnId, dispatch, onlyMedia } = this.props;

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('UNION', { other: { onlyMedia } }));
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
    const { dispatch, onlyMedia } = this.props;

    dispatch(expandUnionTimeline({ onlyMedia }));
    this.disconnect = dispatch(connectUnionStream({ onlyMedia }));
  }

  componentDidUpdate (prevProps) {
    if (prevProps.onlyMedia !== this.props.onlyMedia) {
      const { dispatch, onlyMedia } = this.props;

      this.disconnect();
      dispatch(expandUnionTimeline({ onlyMedia }));
      this.disconnect = dispatch(connectUnionStream({ onlyMedia }));
    }
  }

  componentWillUnmount () {
    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }
  }

  setRef = c => {
    this.column = c;
  }

  handleLoadMore = maxId => {
    const { dispatch, onlyMedia } = this.props;

    dispatch(expandUnionTimeline({ maxId, onlyMedia }));
  }

  handleHeadlineLinkClick = e => {
    const { columnId, dispatch } = this.props;
    const onlyMedia = /\/media$/.test(e.currentTarget.href);

    dispatch(changeColumnParams(columnId, { other: { onlyMedia } }));
  }

  render () {
    const { intl, hasUnread, columnId, multiColumn, onlyMedia } = this.props;
    const pinned = !!columnId;

    const headline = (
      <SectionHeadline
        timelineId='union'
        to='/timelines/union'
        pinned={pinned}
        onlyMedia={onlyMedia}
        onClick={this.handleHeadlineLinkClick}
      />
    );

    return (
      <Column ref={this.setRef}>
        <ColumnHeader
          icon='handshake-o'
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
          prepend={headline}
          alwaysPrepend
          trackScroll={!pinned}
          scrollKey={`union_timeline-${columnId}`}
          timelineId={`union${onlyMedia ? ':media' : ''}`}
          onLoadMore={this.handleLoadMore}
          emptyMessage={<FormattedMessage id='empty_column.union' defaultMessage='There is nothing here! Write something publicly, or manually follow users from other union instances to fill it up' />}
        />
      </Column>
    );
  }

}
