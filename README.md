# Spindle-Firing-Analysis
This script automatically analyzes stretch-induced firing in muscle spindle recordings. It detects sustained increases in activity, segments the response into functional phases, and calculates firing rates relative to baseline. Outputs include raw and background-corrected metrics.
There are two versions of the code, one for ramp stretches and another for saw-like stretches and releases.
Although originally written manually prior to the advent of generative AI tools, the code can now be easily adapted by non-specialists using AI assistants such as ChatGPT (OpenAI, 2024), which also produced some of the documentation.

For previous studies, the software was set up to record data as files containing the date, time and cumulative event counts sampled at 10 Hz, without explicit markers for stretch onset. Examples of our data are also provided as .txt files.

The code identifies the onset of sustained afferent firing by comparing short-term firing rates against an initial background level. A threshold criterion (crit) is used to define significant increases in firing, and the increase must be maintained for a user-defined duration to confirm a valid stretch event. Once a stretch onset is detected, the code extracts average firing rates across predefined phases: initial pause (baseline), stretch, hold 1, hold 2, release, and final pause. Each phase’s activity is calculated from the cumulative data and corrected relative to baseline. The process repeats for a user-defined number of stretch repetitions within each file.

Outputs include: (1) raw phase-wise rates for each repetition; (2) background-corrected values; and (3) file-wise averages. The method balances robustness and flexibility, allowing adjustment of thresholds and durations to accommodate variability in signal quality or pharmacological effects.

Example of command lines in MATLAB to run the codes:
RampAnalysis(1,1,1,2,1,4,4,10,2,'c','Ramp')
SawAnalysis(0.1,5,5,10,10,1,'C','Saw5Hz');
SawAnalysis(0.1,0.2,5,10,10,1,'C','Saw0.2Hz');
SawAnalysis(0.1,1,5,10,10,1,'C','Saw1Hz');

The first parameters describe the type of stretch, including frequency, number of repeats, hold and pauses. For correct identification, the time the firing must be sustained and how much over the background (the last two numerical parameters) must be manually adjusted to correctly identify different regimes: control, agonists and antagonists. The firing start as identified by the code is marked by a coloured circle on the plot.


