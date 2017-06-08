import { connect } from 'react-redux';
import ColumnSettings from '../../community_timeline/components/column_settings';
import { changeSetting, saveSettings } from '../../../actions/settings';

const mapStateToProps = state => ({
  settings: state.getIn(['settings', 'union']),
});

const mapDispatchToProps = dispatch => ({

  onChange (key, checked) {
    dispatch(changeSetting(['union', ...key], checked));
  },

  onSave () {
    dispatch(saveSettings());
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(ColumnSettings);
