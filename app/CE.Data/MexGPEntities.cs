using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CE.Data
{
    public partial class MexGPEntities : DbContext
    {
        public MexGPEntities(String connectionString) : base(connectionString)
        {

        }
    }
}
