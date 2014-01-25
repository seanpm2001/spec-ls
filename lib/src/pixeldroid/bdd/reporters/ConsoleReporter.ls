
package pixeldroid.bdd.reporters
{
	import pixeldroid.bdd.Reporter;
	import pixeldroid.bdd.models.Expectation;
	import pixeldroid.bdd.models.MatchResult;

	public class ConsoleReporter implements Reporter
	{
		private var numFailures:Number;
		private var numSpecs:Number;
		private var numAssert:Number;


		public function begin(name:String, total:Number):void
		{
			numFailures = 0;
			numSpecs = total;
			numAssert = 0;

			trace('');
			trace(name);
		}

		public function report(e:Expectation, index:Number, total:Number):void
		{
			trace(' -should ' +e.description);

			var i:Number;
			var n:Number = e.numResults;
			var result:MatchResult;
			var verdict:String;

			numAssert += n;

			for (i = 0; i < n; i++)
			{
				result = e.getResult(i);
				if (result.success)
				{
					verdict = '.';
				}
				else
				{
					verdict = 'X';
					numFailures++;
				}

				trace(verdict +' expect ' +result.message);
			}

		}

		public function end():void
		{
			var summary:String = '';
			summary += numFailures +' ' +pluralize('failure', numFailures);
			summary += ' in ' +numAssert +' assertions';
			summary += ' from ' +numSpecs +' expectations';
			summary += '.';

			trace(summary);
		}


		private function pluralize(s:String, n:Number):String
		{
			if (n == 0 || n > 1) return s +'s';
			return s;
		}
	}
}
