import React, {Component, PropTypes} from 'react';
import {Table, sort} from 'reactabular';
import {tableLayoutStyles, sortableOptions} from "../tables/tableConstants";
import i18n from '@cdo/locale';
import wrappedSortable from '../tables/wrapped_sortable';
import orderBy from 'lodash/orderBy';

const TABLE_WIDTH = tableLayoutStyles.table.width;
const NAME_COLUMN_WIDTH = 120;
const PADDING = 15;
const PADDING_LEFT = 25;

const styles = {
  studentNameColumnHeader: {
    width: NAME_COLUMN_WIDTH,
    textAlign: 'center',
  },
  studentNameColumnCell : {
    width: NAME_COLUMN_WIDTH,
    paddingLeft: PADDING_LEFT,
  },
  responseColumnHeader: {
    padding: PADDING,
  },
  responseColumnCell: {
    padding: PADDING,
    maxwidth: TABLE_WIDTH - NAME_COLUMN_WIDTH - PADDING_LEFT,
  }
};

export const COLUMNS = {
  STUDENT: 0,
  RESPONSE: 1,
};

const freeResponsesDataPropType = PropTypes.shape({
  id:  PropTypes.number.isRequired,
  studentId: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  response: PropTypes.string.isRequired,
});

class FreeResponsesAssessments extends Component {
  static propTypes= {
    freeResponses: PropTypes.arrayOf(freeResponsesDataPropType),
  };

  state = {
    [COLUMNS.NAME]: {
      direction: 'desc',
      position: 0
    }
  };

  getSortingColumns = () => {
    return this.state.sortingColumns || {};
  };

  onSort = (selectedColumn) => {
    this.setState({
      sortingColumns: sort.byColumn({
        sortingColumns: this.state.sortingColumns,
        sortingOrder: {
          FIRST: 'asc',
          asc: 'desc',
          desc: 'asc',
        },
        selectedColumn
      })
    });
  };

  studentResponseColumnFormatter = (response, {rowIndex}) => {
   const studentResponse = this.props.freeResponses[rowIndex].response;

    return (
      <div>
        {studentResponse}
      </div>
    );
  };

  studentNameColumnFormatter = (name, {rowIndex}) => {
    const studentName = this.props.freeResponses[rowIndex].name;

    return (
      <div>
      {studentName}
      </div>
    );
  };

  getColumns = (sortable, index) => {
    let dataColumns = [
      {
        property: 'studentName',
        header: {
          label: i18n.studentName(),
          props: {
            style: {
              ...tableLayoutStyles.headerCell,
              ...styles.studentNameColumnHeader,
            }
          },
        },
        cell: {
          format: this.studentNameColumnFormatter,
          props: {
            style: {
              ...tableLayoutStyles.cell,
              ...styles.studentNameColumnCell,
            }
          },

        }
      },
      {
        property: 'studentResponse',
        header: {
          label: i18n.response(),
          props: {
            style: {
              ...tableLayoutStyles.headerCell,
              ...styles.responseHeaderCell,
            }
          },
        },
        cell: {
          format: this.studentResponseColumnFormatter,
          props: {
            style: {
              ...tableLayoutStyles.cell,
              ...styles.responseColumnCell,
            }
          },

        }
      },
    ];
    return dataColumns;
  };

  render() {
    // Define a sorting transform that can be applied to each column
    const sortable = wrappedSortable(this.getSortingColumns, this.onSort, sortableOptions);
    const columns = this.getColumns(sortable);
    const sortingColumns = this.getSortingColumns();

    const sortedRows = sort.sorter({
      columns,
      sortingColumns,
      sort: orderBy,
    })(this.props.freeResponses);

    return (
        <Table.Provider
          columns={columns}
          style={tableLayoutStyles.table}
        >
          <Table.Header />
          <Table.Body rows={sortedRows} rowKey="id" />
        </Table.Provider>
    );
  }
}

export default FreeResponsesAssessments;
